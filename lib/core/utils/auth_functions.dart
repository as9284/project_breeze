import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Login function
Future<void> signIn(context, emailController, passwordController) async {
  String email = emailController.text;
  String password = passwordController.text;

  try {
    final AuthResponse res = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    Navigator.pushReplacementNamed(context, "/home");
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
  }
}

// Signup Function
Future<void> signUp(context, emailController, passwordController) async {
  String email = emailController.text;
  String password = passwordController.text;

  try {
    final AuthResponse res = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    Navigator.pushReplacementNamed(context, "/home");
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
  }
}

// Logout function
Future<void> signOut(context) async {
  await supabase.auth.signOut();

  Navigator.pushReplacementNamed(context, "/signup");
}
