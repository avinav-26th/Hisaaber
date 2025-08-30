// In lib/screens/splash_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/api_services/database_service.dart'; // We use our service
import 'package:hisaaber_v1/screens/auth/login_screen.dart';
import 'package:hisaaber_v1/screens/home_screen.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:hisaaber_v1/utils/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatusAndNavigate();
  }
  // In SplashScreen -> _checkAuthStatusAndNavigate
  void _checkAuthStatusAndNavigate() async {
    final dbService = DatabaseService();
    await Future.delayed(const Duration(seconds: 2));

    print('DEBUG: SplashScreen is checking auth status...'); // <-- ADD THIS
    final isLoggedIn = await dbService.hasDummySession();
    print('DEBUG: SplashScreen determined isLoggedIn = $isLoggedIn'); // <-- ADD THIS

    if (mounted) {
      if (isLoggedIn) {
        print('DEBUG: Navigating to HomeScreen.'); // <-- ADD THIS
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        print('DEBUG: Navigating to LoginScreen.'); // <-- ADD THIS
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }
  // This method now ONLY checks our local Hive database
  // void _checkAuthStatusAndNavigate() async {
  //   final dbService = DatabaseService();
  //   await Future.delayed(const Duration(seconds: 2));
  //
  //   final isLoggedIn = await dbService.hasDummySession();
  //
  //   if (mounted) {
  //     if (isLoggedIn) {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => const HomeScreen()),
  //       );
  //     } else {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (context) => const LoginScreen()),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryWhite,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/hisaaber_logo.png', // Make sure this path exactly matches your file
              width: 150, // You can adjust the size here
            ),
            SizedBox(height: 24),
            Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




// // In lib/screens/splash_screen.dart
//
// import 'dart:async';
// import 'package:flutter/material.dart';
// // import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hisaaber_v1/screens/auth/login_screen.dart';
// import 'package:hisaaber_v1/screens/home_screen.dart';
// import 'package:hisaaber_v1/utils/app_colors.dart';
// import 'package:hisaaber_v1/utils/constants.dart';
// import 'package:hisaaber_v1/api_services/database_service.dart';
//
// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }
//
// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _checkAuthStatusAndNavigate();
//   }
//
//   // void _checkAuthStatusAndNavigate() {
//   //   // Wait for a short duration to show the splash screen
//   //   Timer(const Duration(seconds: 2), () {
//   //     // Check for the current user with Firebase Auth
//   //     final user = FirebaseAuth.instance.currentUser;
//   //
//   //     if (mounted) {
//   //       if (user != null) {
//   //         // If user is logged in, go to HomeScreen
//   //         Navigator.of(context).pushReplacement(
//   //           MaterialPageRoute(builder: (context) => const HomeScreen()),
//   //         );
//   //       } else {
//   //         // If user is not logged in, go to LoginScreen
//   //         Navigator.of(context).pushReplacement(
//   //           MaterialPageRoute(builder: (context) => const LoginScreen()),
//   //         );
//   //       }
//   //     }
//   //   });
//   // }
//   void _checkAuthStatusAndNavigate() async { // Make it async
//     final dbService = DatabaseService();
//     // Wait for a short duration to show the splash screen
//     await Future.delayed(const Duration(seconds: 2));
//
//     // Check for our dummy session instead of a Firebase user
//     final isLoggedIn = await dbService.hasDummySession();
//
//     if (mounted) {
//       if (isLoggedIn) {
//         // If "logged in", go to HomeScreen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const HomeScreen()),
//         );
//       } else {
//         // If not "logged in", go to LoginScreen
//         Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => const LoginScreen()),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       backgroundColor: AppColors.primaryWhite,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Placeholder for your app icon/logo
//             Icon(
//               Icons.calculate, // Replace with your actual app logo
//               size: 120,
//               color: AppColors.primaryGreen,
//             ),
//             SizedBox(height: 24),
//             Text(
//               AppConstants.appName,
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
