import "package:flutter/material.dart";
import "package:project_breeze/views/home.dart";
import "package:project_breeze/views/signup.dart";
import "package:supabase_flutter/supabase_flutter.dart";

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // If user is logged in
        if (session != null && session.user != null) {
          return HomePage();
        }

        // Otherwise, show sign up screen
        return SignupPage();
      },
    );
  }
}
