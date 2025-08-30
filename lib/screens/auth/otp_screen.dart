// In lib/screens/auth/otp_screen.dart

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart';
import 'package:hisaaber_v1/screens/home_screen.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:hisaaber_v1/widgets/primary_button.dart';
import 'package:pinput/pinput.dart';

class OTPScreen extends StatefulWidget {
  final String verificationId; // We keep this for structure, though it's a dummy value now
  final String phoneNumber;
  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController _pinController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  bool _isLoading = false;

  // For the timer and resend logic
  Timer? _timer;
  int _start = 60; // Countdown time
  bool _isResendEnabled = false;
  String _dummyOtp = ''; // This will now hold our random OTP
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    startTimer();
    _simulateOtpArrival();
  }

  void startTimer() {
    setState(() => _isResendEnabled = false);
    _start = 60;
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (Timer timer) {
        if (_start == 0) {
          if (mounted) {
            setState(() {
              _isResendEnabled = true;
              timer.cancel();
            });
          }
        } else {
          if (mounted) {
            setState(() => _start--);
          }
        }
      },
    );
  }

  // This is a new helper method
  // In lib/screens/auth/otp_screen.dart -> _OTPScreenState

// This is a new helper method
  void _generateAndSetOtp() {
    // Generate a random 6-digit number between 100000 and 999999
    _dummyOtp = (100000 + _random.nextInt(900000)).toString();
    print('DEBUG: Generated Dummy OTP is $_dummyOtp'); // For testing
  }

  // In lib/screens/auth/otp_screen.dart -> _OTPScreenState

  void _simulateOtpArrival() {
    _generateAndSetOtp();

    // Step 1: Wait 2 seconds to simulate the SMS arriving.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        // Auto-fill the OTP boxes.
        _pinController.setText(_dummyOtp);

        // Step 2: Wait another 1.5 seconds so the user can see the filled OTP.
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            // Now, perform the verification and navigate.
            _verifyOtp();
          }
        });
      }
    });
  }

  void _resendOtp() {
    _generateAndSetOtp(); // Generate a new OTP on resend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('A new dummy OTP ($_dummyOtp) has been sent.')),
    );
    startTimer();
    _simulateOtpArrival();
  }

  void _verifyOtp() async {
    if (_pinController.text != _dummyOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid OTP. Please use $_dummyOtp.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await _databaseService.createDummySession(widget.phoneNumber);

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: Colors.black),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verification')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 32),
              Pinput(
                length: 6,
                controller: _pinController,
                defaultPinTheme: defaultPinTheme,
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    border: Border.all(color: AppColors.primaryGreen),
                  ),
                ),
                // onCompleted: (pin) => _verifyOtp(),
              ),
              const SizedBox(height: 32),
              _isResendEnabled
                  ? TextButton(
                onPressed: _resendOtp,
                child: const Text('Resend OTP'),
              )
                  : Text('Resend OTP in 00:${_start.toString().padLeft(2, '0')}'),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : PrimaryButton(
                text: 'Verify',
                onPressed: _verifyOtp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}










// // In lib/screens/auth/otp_screen.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:hisaaber_v1/providers/auth_provider.dart';
// import 'package:hisaaber_v1/screens/home_screen.dart';
// import 'package:hisaaber_v1/utils/app_colors.dart';
// import 'package:hisaaber_v1/widgets/primary_button.dart';
// import 'package:pinput/pinput.dart';
// import 'package:provider/provider.dart';
//
// class OTPScreen extends StatefulWidget {
//   final String verificationId;
//   final String phoneNumber; // <-- ADD THIS
//   const OTPScreen({
//     super.key,
//     required this.verificationId,
//     required this.phoneNumber, // <-- ADD THIS
//   });
//
//   @override
//   State<OTPScreen> createState() => _OTPScreenState();
// }
//
// class _OTPScreenState extends State<OTPScreen> {
//   final TextEditingController _pinController = TextEditingController();
//   late String _currentVerificationId; // Use a state variable
//   Timer? _timer;
//   int _start = 60;
//   bool _isResendEnabled = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentVerificationId = widget.verificationId; // Initialize with the first ID
//     startTimer();
//   }
//
//   void startTimer() {
//     setState(() {
//       _isResendEnabled = false;
//       _start = 60;
//     });
//     _timer = Timer.periodic(
//       const Duration(seconds: 1),
//       (Timer timer) {
//         if (_start == 0) {
//           setState(() {
//             _isResendEnabled = true;
//             timer.cancel();
//           });
//         } else {
//           setState(() {
//             _start--;
//           });
//         }
//       },
//     );
//   }
//
//   void _resendOtp() {
//     final authProvider = context.read<AuthProvider>();
//     authProvider.verifyPhoneNumber(
//       phoneNumber: widget.phoneNumber,
//       onCodeSent: (newVerificationId, resendToken) {
//         // When the new code is sent, update the verification ID
//         setState(() {
//           _currentVerificationId = newVerificationId;
//         });
//         startTimer(); // Restart the timer
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('A new OTP has been sent.')),
//         );
//       },
//     );
//   }
//
//   void _verifyOtp(String pin) async {
//     final authProvider = context.read<AuthProvider>();
//
//     print('DEBUG: Attempting to sign in with Verification ID: $_currentVerificationId and OTP: $pin');
//
//     final isSuccess = await authProvider.signInWithOtp(
//       verificationId: _currentVerificationId,
//       smsCode: pin,
//     );
//
//     if (mounted) {
//       if (isSuccess) {
//         Navigator.of(context).pushAndRemoveUntil(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//           (Route<dynamic> route) => false,
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(authProvider.errorMessage ?? 'Invalid OTP')),
//         );
//       }
//     }
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pinController.dispose();
//     super.dispose();
//   }
//
//   // ... (build method remains the same)
//   @override
//   Widget build(BuildContext context) {
//     final authProvider = context.watch<AuthProvider>();
//
//     final defaultPinTheme = PinTheme(
//       width: 56,
//       height: 60,
//       textStyle: const TextStyle(fontSize: 22, color: Colors.black),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.transparent),
//       ),
//     );
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('OTP Verification'),
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const SizedBox(height: 40),
//               const Text(
//                 'Enter the 6-digit code sent to your mobile number',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(fontSize: 18),
//               ),
//               const SizedBox(height: 32),
//               Pinput(
//                 length: 6,
//                 controller: _pinController,
//                 defaultPinTheme: defaultPinTheme,
//                 focusedPinTheme: defaultPinTheme.copyWith(
//                   decoration: defaultPinTheme.decoration!.copyWith(
//                     border: Border.all(color: AppColors.primaryGreen),
//                   ),
//                 ),
//                 onCompleted: (pin) => _verifyOtp(pin),
//               ),
//               const SizedBox(height: 32),
//               _isResendEnabled
//                   ? TextButton(
//                       onPressed: _resendOtp, // <-- CALL THE NEW METHOD
//                       child: const Text('Resend OTP'),
//                     )
//                   : Text('Resend OTP in 00:${_start.toString().padLeft(2, '0')}'),
//               const SizedBox(height: 32),
//               authProvider.isLoading
//                   ? const CircularProgressIndicator()
//                   : PrimaryButton(
//                       text: 'Verify',
//                       onPressed: () {
//                         if (_pinController.text.length == 6) {
//                           _verifyOtp(_pinController.text);
//                         }
//                       },
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }