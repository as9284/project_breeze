import 'package:flutter/material.dart';
import 'package:breeze/core/utils/toaster_helpers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toastification/toastification.dart';

final supabase = Supabase.instance.client;

// Login function
Future<void> signIn(context, emailController, passwordController) async {
  String email = emailController.text;
  String password = passwordController.text;

  try {
    // ignore: unused_local_variable
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    showToast(
      context: context,
      message: "Welcome back! :D",
      type: ToastificationType.success,
    );
    Navigator.pushReplacementNamed(context, "/home");
  } catch (e) {
    showToast(
      context: context,
      message: "Error: $e",
      type: ToastificationType.error,
    );
  }
}

// Signup Function
Future<void> signUp(context, emailController, passwordController) async {
  String email = emailController.text;
  String password = passwordController.text;

  try {
    // ignore: unused_local_variable
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    showToast(
      context: context,
      message: "Welcome to Breeze! :D",
      type: ToastificationType.success,
    );
    Navigator.pushReplacementNamed(context, "/home");
  } catch (e) {
    showToast(
      context: context,
      message: "Error: $e",
      type: ToastificationType.error,
    );
  }
}

// Logout function
Future<void> signOut(context) async {
  await supabase.auth.signOut();

  showToast(
    context: context,
    message: "See you soon! :)",
    type: ToastificationType.success,
  );
  Navigator.pushReplacementNamed(context, "/signup");
}
