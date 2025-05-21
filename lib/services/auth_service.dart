import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> phoneSignIn(String phoneNumber) async {
    Completer<String> completer = Completer<String>();
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        if (!completer.isCompleted) completer.complete('auto-verified');
      },
      verificationFailed: (FirebaseAuthException e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (!completer.isCompleted) completer.complete(verificationId);
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
    return completer.future;
  }

  Future<UserCredential> verifyOTP(String verificationId, String otp) async {
    final credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: otp);
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async => await _auth.signOut();

  Future<bool> userExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);
    return null;
  }
}
