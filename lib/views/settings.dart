import 'package:breeze/core/utils/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatefulWidget {
  final void Function(bool) onThemeChanged;
  final bool isDarkMode;

  const SettingsPage({
    super.key,
    required this.onThemeChanged,
    required this.isDarkMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _darkMode;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.isDarkMode;
  }

  final Uri _url = Uri.parse('https://github.com/as9284/project_breeze');

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                  child: Text(
                    "General Settings",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                SwitchListTile(
                  title: const Text("Dark Mode"),
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                    widget.onThemeChanged(value);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text("Log Out"),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Logout"),
                            content: const Text(
                              "Are you sure you want to logout?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Logout",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      signOut(context);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    "Delete Account",
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: const Text("Delete Account"),
                            content: const Text(
                              "Are you sure you want to permanently delete your account? This action cannot be undone.",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                    );

                    if (confirm == true) {
                      final user = Supabase.instance.client.auth.currentUser;

                      if (user != null) {
                        final response = await http.delete(
                          Uri.parse(
                            'https://xnlydvwnpnbbzduagtzb.supabase.co/functions/v1/delete-user',
                          ),
                          headers: {'Content-Type': 'application/json'},
                          body: json.encode({'userId': user.id}),
                        );

                        if (response.statusCode == 200) {
                          await Supabase.instance.client.auth.signOut();
                        }
                      }
                    }
                  },
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 20, bottom: 10),
                  child: Text(
                    "About",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text("App Version"),
                  subtitle: const Text("1.0.0"),
                ),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text("View Source Code"),
                  onTap: () async {
                    _launchUrl();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "Made with ❤️ by Anthony Saliba",
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
