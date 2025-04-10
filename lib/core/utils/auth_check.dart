import "package:flutter/material.dart";
import "package:breeze/views/home.dart";
import "package:breeze/views/signup.dart";
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
        if (session != null) {
          return HomePage();
        }

        // Otherwise, show sign up screen
        return SignupPage();
      },
    );
  }
}
