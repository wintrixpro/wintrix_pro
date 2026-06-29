import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

enum RegisterState { idle, loading, otpSent, success, error }

class RegisterProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  RegisterState _state = RegisterState.idle;
  RegisterState get state => _state;

  String _errorMessage = "";
  String get errorMessage => _errorMessage;

  String _verificationId = "";
  int _timerSeconds = 60;
  int get timerSeconds => _timerSeconds;
  Timer? _countDownTimer;

  RegisterProvider(this._authRepository);

  void _changeState(RegisterState newState, [String error = ""]) {
    _state = newState;
    _errorMessage = error;
    notifyListeners();
  }

  void startTimer() {
    _timerSeconds = 60;
    _countDownTimer?.cancel();
    _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _countDownTimer?.cancel();
      }
    });
  }

  /// 1. फ़ोन नंबर की उपलब्धता की जांच और OTP भेजना
  Future<void> initiatePhoneRegistration({
    required String firstName,
    required String lastName,
    required String rawPhone,
    required String password,
    required String referral,
  }) async {
    _changeState(RegisterState.loading);
    final formattedPhone = "+91$rawPhone";

    try {
      final dbRef = FirebaseDatabase.instance.ref().child('profiles');
      final query = await dbRef.orderByChild('phone').equalTo(formattedPhone).get();

      if (query.exists) {
        _changeState(RegisterState.error, "This number is already registered. Please login.");
        return;
      }

      await _authRepository.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        onVerificationCompleted: (credential) async {
          await _processAccountCreation(credential, firstName, lastName, formattedPhone, password, referral);
        },
        onVerificationFailed: (exception) {
          _changeState(RegisterState.error, exception.message ?? "Verification Failed.");
        },
        onCodeSent: (verId, _) {
          _verificationId = verId;
          startTimer();
          _changeState(RegisterState.otpSent);
        },
      );
    } catch (e) {
      _changeState(RegisterState.error, e.toString());
    }
  }

  /// 2. OTP कोड मैन्युअली सबमिट करना
  Future<void> submitManualOtp(String smsCode, String fName, String lName, String phone, String pass, String ref) async {
    _changeState(RegisterState.loading);
    try {
      final credential = PhoneAuthProvider.credential(verificationId: _verificationId, smsCode: smsCode);
      await _processAccountCreation(credential, fName, lName, phone, pass, ref);
    } catch (e) {
      _changeState(RegisterState.error, "Invalid OTP code configuration.");
    }
  }

  Future<void> _processAccountCreation(PhoneAuthCredential credential, String fName, String lName, String phone, String pass, String ref) async {
    try {
      final cleanPhone = phone.replaceAll("+", "");
      final fakeEmail = "$cleanPhone@wintrix.app";

      UserCredential userCreds = await _authRepository.registerWithPhoneAuth(fakeEmail: fakeEmail, password: pass);
      
      if (userCreds.user != null) {
        await _authRepository.linkCredentials(user: userCreds.user!, credential: credential);
        
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final profile = UserEntity(
          uid: userCreds.user!.uid,
          name: "$fName $lName",
          phone: phone,
          email: fakeEmail,
          referredBy: ref,
          isBanned: false,
          profilePic: "",
          createdAt: timestamp,
          updatedAt: timestamp,
        );

        await _authRepository.saveUserProfile(profile);
        await _saveLocalPrefs(userCreds.user!.uid, "$fName $lName", phone);
        _changeState(RegisterState.success);
      }
    } on FirebaseAuthException catch (e) {
      _changeState(RegisterState.error, e.message ?? "Authentication failed.");
    } catch (e) {
      _changeState(RegisterState.error, "Database structure mismatch occurred.");
    }
  }

  /// 3. Google साइन-इन मैकेनिज्म
  Future<void> loginWithGoogle() async {
    _changeState(RegisterState.loading);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: "1062545272781-ghb0gc2m8t47bpks6ta7vl863la3g91o.apps.googleusercontent.com",
      );
      await googleSignIn.signOut();
      final GoogleSignInAccount? account = await googleSignIn.signIn();

      if (account == null) {
        _changeState(RegisterState.idle);
        return;
      }

      final GoogleSignInAuthentication authAuth = await account.authentication;
      if (authAuth.idToken == null) {
        _changeState(RegisterState.error, "Google authentication token acquisition failed.");
        return;
      }

      UserCredential creds = await _authRepository.signInWithGoogle(authAuth.idToken!);
      if (creds.user != null) {
        final existingProfile = await _authRepository.checkExistingProfile(creds.user!.uid);

        if (existingProfile != null) {
          if (existingProfile['is_banned'] == true) {
            await FirebaseAuth.instance.signOut();
            _changeState(RegisterState.error, "BANNED_USER");
            return;
          }
          await _saveLocalPrefs(creds.user!.uid, existingProfile['name'] ?? 'Player', '');
        } else {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final newProfile = UserEntity(
            uid: creds.user!.uid,
            name: creds.user!.displayName ?? "Player",
            phone: "",
            email: creds.user!.email ?? "",
            referredBy: "",
            isBanned: false,
            profilePic: creds.user!.photoURL ?? "",
            createdAt: timestamp,
            updatedAt: timestamp,
          );
          await _authRepository.saveUserProfile(newProfile);
          await _saveLocalPrefs(creds.user!.uid, newProfile.name, '');
        }
        _changeState(RegisterState.success);
      }
    } catch (e) {
      _changeState(RegisterState.error, "Google processing error: ${e.toString()}");
    }
  }

  Future<void> _saveLocalPrefs(String uid, String name, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("userId", uid);
    await prefs.setString("userName", name);
    await prefs.setString("phone", phone);
    await prefs.setBool("isLoggedIn", true);
    await prefs.setString("userEmail", phone.isNotEmpty ? "${phone.replaceAll("+", "")}@wintrix.app" : name);
  }

  @override
  void dispose() {
    _countDownTimer?.cancel();
    super.dispose();
  }
}
