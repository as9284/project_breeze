import 'package:breeze/views/settings.dart';
import 'package:flutter/material.dart';
import 'package:breeze/core/constants.dart';
import 'package:breeze/core/utils/auth_check.dart';
import 'package:breeze/views/home.dart';
import 'package:breeze/views/login.dart';
import 'package:breeze/views/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

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
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: _themeMode,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        "/home": (context) => const HomePage(),
        "/settings":
            (context) => SettingsPage(
              onThemeChanged: _toggleTheme,
              isDarkMode: _themeMode == ThemeMode.dark,
            ),
      },
      home: const AuthCheck(),
    );
  }
}
