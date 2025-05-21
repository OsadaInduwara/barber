// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  authenticating,
  unauthenticated,
  error
}

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _firebaseUser;
  UserModel? _currentUser;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _error;
  String? _verificationId;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  // Constructor - Initialize auth state
  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // Handle auth state changes
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _firebaseUser = null;
      _currentUser = null;
    } else {
      _firebaseUser = firebaseUser;
      await _fetchUserData();
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final doc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();

      if (doc.exists) {
        _currentUser = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
    }
  }

  // Sign in with phone
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      _status = AuthStatus.authenticating;
      _error = null;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verify on Android devices
          await _auth.signInWithCredential(credential);
          _status = AuthStatus.authenticated;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          _error = e.message;
          _status = AuthStatus.error;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _status = AuthStatus.authenticating;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String smsCode) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      _firebaseUser = userCredential.user;

      // Check if this is a new user
      final userDoc = await _firestore.collection('users').doc(_firebaseUser!.uid).get();

      if (!userDoc.exists) {
        // Create a new user document
        final newUser = UserModel(
          uid: _firebaseUser!.uid,
          displayName: _firebaseUser!.displayName ?? '',
          phoneNumber: _firebaseUser!.phoneNumber!,
          email: _firebaseUser!.email,
          role: 'customer', // Default role
          createdAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(_firebaseUser!.uid).set(newUser.toMap());
        _currentUser = newUser;
      } else {
        _currentUser = UserModel.fromMap(userDoc.data()!);
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _firebaseUser = null;
    notifyListeners();
  }

  // Update user profile
  Future<void> updateUserProfile({String? displayName, String? email}) async {
    try {
      if (_firebaseUser != null) {
        if (displayName != null) {
          await _firebaseUser!.updateDisplayName(displayName);
        }

        if (email != null && email.isNotEmpty) {
          await _firebaseUser!.updateEmail(email);
        }

        // Update Firestore data
        final updatedData = {
          if (displayName != null) 'displayName': displayName,
          if (email != null) 'email': email,
        };

        await _firestore.collection('users').doc(_firebaseUser!.uid).update(updatedData);

        // Refresh user data
        await _fetchUserData();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }

  // Set barber role
  Future<void> setBarberRole() async {
    try {
      if (_firebaseUser != null) {
        await _firestore.collection('users').doc(_firebaseUser!.uid).update({
          'role': 'barber',
        });

        await _fetchUserData();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      throw e;
    }
  }
}


