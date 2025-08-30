// In lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/providers/auth_provider.dart';
import 'package:hisaaber_v1/screens/auth/otp_screen.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:hisaaber_v1/utils/constants.dart';
import 'package:hisaaber_v1/widgets/primary_button.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // final authProvider = context.read<AuthProvider>();
      final phoneNumber = '+91${_phoneController.text.trim()}';

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPScreen(
            // We still pass the phone number, as we'll need it
            phoneNumber: phoneNumber,
            // We don't have a real verificationId anymore
            verificationId: 'dummy-verification-id',
          ),
        ),
      );

      // // We listen for errors here
      // authProvider.addListener(() {
      //   if (authProvider.errorMessage != null) {
      //     ScaffoldMessenger.of(context).showSnackBar(
      //       SnackBar(content: Text(authProvider.errorMessage!)),
      //     );
      //   }
      // });

      // authProvider.verifyPhoneNumber(
      //   phoneNumber: phoneNumber,
      //   onCodeSent: (verificationId, resendToken) {
      //     // When the code is sent, navigate to the OTP screen
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => OTPScreen(verificationId: verificationId, phoneNumber: phoneNumber,),
      //       ),
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use a Consumer to listen for loading state changes
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 60),

                  // Placeholder for a cute vector graphic
                  const Icon(
                    Icons.storefront_outlined,
                    size: 100,
                    color: AppColors.primaryGreen,
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Welcome to Hisaaber!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Your simple solution for daily accounting.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black.withAlpha((255 * 0.6).round()),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  // Phone Number Input Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: AppConstants.mobileNumber,
                      prefixText: '+91 ',
                      counterText: '', // Hides the character counter
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length != 10) {
                        return 'Please enter a valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Send OTP Button with Loading Indicator
                  authProvider.isLoading
                      ? const CircularProgressIndicator()
                      : PrimaryButton(
                          text: 'Send OTP',
                          onPressed: _sendOtp,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}