import 'package:firebase_auth/firebase_auth.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
  });

  Future<UserCredential> registerWithPhoneAuth({
    required String fakeEmail,
    required String password,
  });

  Future<UserCredential> linkCredentials({
    required User user,
    required PhoneAuthCredential credential,
  });

  Future<void> saveUserProfile(UserEntity userEntity);

  Future<UserCredential> signInWithGoogle(String idToken);

  Future<Map<String, dynamic>?> checkExistingProfile(String uid);
}
