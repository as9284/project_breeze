import 'package:flutter/material.dart';
import 'package:breeze/core/constants.dart';
import 'package:breeze/core/utils/auth_check.dart';
import 'package:breeze/views/home.dart';
import 'package:breeze/views/login.dart';
import 'package:breeze/views/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Breeze",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        "/home": (context) => const HomePage(),
      },
      home: AuthCheck(),
    );
  }
}
