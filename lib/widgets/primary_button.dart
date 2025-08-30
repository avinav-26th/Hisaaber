// In lib/widgets/primary_button.dart

import 'package:flutter/material.dart';
import 'package:hisaaber_v1/utils/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? verticalPadding;
  final double? borderRadius;
  final double? fontSize;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.verticalPadding,
    this.borderRadius,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity, // Use the provided width, or let it size itself
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.black,
          textStyle: TextStyle(
            color: Colors.white,
            fontSize: fontSize ?? 20,
            fontWeight: FontWeight.w400,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12), // Use new radius
          ),
          padding: EdgeInsets.symmetric(vertical: verticalPadding ?? 16), // Use new padding
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize ?? 18, fontWeight: FontWeight.bold), // Use new font size
        ),
      ),
    );
  }
}