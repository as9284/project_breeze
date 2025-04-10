import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

// Reusable toast function
void showToast({
  required BuildContext context,
  required String message,
  required ToastificationType type,
  Color? primaryColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  toastification.show(
    context: context,
    primaryColor:
        primaryColor ??
        (type == ToastificationType.success ? Colors.green : Colors.red),
    applyBlurEffect: true,
    closeOnClick: true,
    autoCloseDuration: Duration(seconds: 3),
    showProgressBar: true,
    type: type,
    title: Text(message),
    backgroundColor:
        isDark
            ? const Color.fromARGB(100, 0, 0, 0)
            : const Color.fromARGB(100, 255, 255, 255),
    foregroundColor: isDark ? Colors.white : Colors.black,
  );
}
