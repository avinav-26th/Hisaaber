// In lib/api_services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  // Create an instance of Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- GETTERS ---

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // --- METHODS ---

  /// Starts the phone number verification process
  ///
  /// This requires callback functions from the UI to handle different events.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber, // The user's phone number
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  /// Signs the user in with the verification ID and the OTP code
  Future<UserCredential?> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Sign the user in with the credential
      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle potential errors like invalid OTP
      debugPrint("Failed to sign in with OTP: ${e.message}");
      return null;
    }
  }

  /// Signs the user in with a pre-made credential (for auto-retrieval on Android)
Future<UserCredential?> signInWithCredential(PhoneAuthCredential credential) async {
  try {
    final userCredential = await _auth.signInWithCredential(credential);
    return userCredential;
  } on FirebaseAuthException catch (e) {
    debugPrint("Failed to sign in with credential: ${e.message}");
    return null;
  }
}
  /// Signs the current user out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}