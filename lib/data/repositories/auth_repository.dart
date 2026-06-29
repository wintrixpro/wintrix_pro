import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // साइन अप करने का प्रोफेशनल तरीका
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String mobile,
  }) async {
    try {
      // 1. Firebase Auth में यूजर बनाओ
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Firestore में यूजर का डेटा सेव करो
      await _firestore.collection('profiles').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'mobile': mobile,
        'balance': 0.0,
        'kyc_status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception("साइन अप में दिक्कत आई: $e");
    }
  }

  // लॉग-आउट का फंक्शन
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
