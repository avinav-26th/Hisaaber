// In lib/providers/auth_provider.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  // --- PRIVATE STATE VARIABLES ---
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // --- GETTERS ---
  // These allow the UI to access the state without modifying it directly.
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- CONSTRUCTOR ---
  AuthProvider() {
    // When the provider is created, check if a user is already logged in.
    _user = _authService.currentUser;
  }

  // --- PUBLIC METHODS ---

  /// Kicks off the phone number verification process.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String, int?) onCodeSent, // Add this parameter
  }) async {
    _setLoading(true);
    _clearError();
    if (kDebugMode) {
      print('DEBUG: AuthProvider received request. Calling Firebase...');
    }

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        if (kDebugMode) {
          print('DEBUG: Verification completed automatically!');
        }
        // For Android auto-retrieval, sign in directly with the credential
        await _authService.signInWithCredential(credential);
        _user = _authService.currentUser;
        _setLoading(false);
      },
      verificationFailed: (FirebaseAuthException e) {
        if (kDebugMode) {
          print('DEBUG: Verification FAILED! Error: ${e.message}');
        }
        _errorMessage = "Verification Failed: ${e.message}";
        _setLoading(false);
      },
      codeSent: (String verificationId, int? resendToken) {
        if (kDebugMode) {
          print('DEBUG: Code sent successfully! Verification ID: $verificationId');
        }
        // Call our new callback function here
        onCodeSent(verificationId, resendToken);
        _setLoading(false);
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        if (kDebugMode) {
          print('DEBUG: Auto-retrieval timed out.');
        }
      },
    );
  }

  /// Signs the user in using the OTP they provided.
  Future<bool> signInWithOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    _setLoading(true);
    _clearError();

    final userCredential = await _authService.signInWithOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    if (userCredential != null) {
      _user = userCredential.user;
      _setLoading(false);
      return true; // Login successful
    } else {
      _errorMessage = "Invalid OTP. Please try again.";
      _setLoading(false);
      return false; // Login failed
    }
  }

  /// Signs the current user out.
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  // --- HELPER METHODS ---

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners(); // Tell the UI to rebuild
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
