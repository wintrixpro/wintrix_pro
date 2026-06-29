import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  @override
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) onVerificationCompleted,
    required Function(FirebaseAuthException) onVerificationFailed,
    required Function(String, int?) onCodeSent,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: onVerificationCompleted,
      verificationFailed: onVerificationFailed,
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  @override
  Future<UserCredential> registerWithPhoneAuth({
    required String fakeEmail,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: fakeEmail,
      password: password,
    );
  }

  @override
  Future<UserCredential> linkCredentials({
    required User user,
    required PhoneAuthCredential credential,
  }) async {
    return await user.linkWithCredential(credential);
  }

  @override
  Future<void> saveUserProfile(UserEntity userEntity) async {
    final model = UserModel(
      uid: userEntity.uid,
      name: userEntity.name,
      phone: userEntity.phone,
      email: userEntity.email,
      referredBy: userEntity.referredBy,
      isBanned: userEntity.isBanned,
      profilePic: userEntity.profilePic,
      createdAt: userEntity.createdAt,
      updatedAt: userEntity.updatedAt,
    );
    await _db.ref().child('profiles').child(userEntity.uid).set(model.toMap());
  }

  @override
  Future<UserCredential> signInWithGoogle(String idToken) async {
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<Map<String, dynamic>?> checkExistingProfile(String uid) async {
    final snapshot = await _db.ref().child('profiles').child(uid).get();
    if (snapshot.exists && snapshot.value is Map) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }
}
