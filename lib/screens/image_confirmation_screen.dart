// In lib/screens/image_confirmation_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hisaaber_v1/providers/bill_provider.dart';
import 'package:hisaaber_v1/screens/total_screen.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ImageConfirmationScreen extends StatefulWidget {
  final String imagePath;
  const ImageConfirmationScreen({super.key, required this.imagePath});

  @override
  State<ImageConfirmationScreen> createState() => _ImageConfirmationScreenState();
}

class _ImageConfirmationScreenState extends State<ImageConfirmationScreen> {
  bool _isProcessing = false;

  void _onProceed() async {
    setState(() => _isProcessing = true);

    final billProvider = context.read<BillProvider>();
    await billProvider.processImageAndParse(widget.imagePath);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TotalScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Image.file(File(widget.imagePath), fit: BoxFit.contain),
          ),
          if (_isProcessing) ...[
            Container(color: Colors.black.withAlpha((255 * 0.7).round())),
            const Center(child: CircularProgressIndicator(color: Colors.white)),
          ] else
            Positioned(
              bottom: 50,
              left: 24,
              right: 24,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FloatingActionButton(
                    heroTag: 'retakeBtn',
                    onPressed: () => Navigator.pop(context), // Just go back
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.replay),
                  ),
                  FloatingActionButton(
                    heroTag: 'proceedBtn',
                    onPressed: _onProceed,
                    backgroundColor: AppColors.primaryGreen,
                    child: const Icon(Icons.check),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}