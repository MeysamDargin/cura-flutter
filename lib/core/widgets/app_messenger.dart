import 'package:flutter/material.dart';

void showAppMessage(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: const TextStyle(fontFamily: 'nova', color: Colors.white),
      ),
      backgroundColor: backgroundColor.withValues(alpha: 0.9),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
