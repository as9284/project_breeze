import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

// Reusable toast function
void showToast({
  required BuildContext context,
  required String message,
  required ToastificationType type,
  Color? primaryColor,
}) {
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
  );
}
