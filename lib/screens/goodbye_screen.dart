// In lib/screens/goodbye_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/screens/auth/login_screen.dart';

class GoodByeScreen extends StatefulWidget {
  const GoodByeScreen({super.key});

  @override
  State<GoodByeScreen> createState() => _GoodByeScreenState();
}

class _GoodByeScreenState extends State<GoodByeScreen> {
  @override
  void initState() {
    super.initState();
    // After 3 seconds, navigate to the LoginScreen
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Good bye!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Come again soon, we will miss you.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}