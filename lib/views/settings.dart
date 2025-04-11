import 'package:breeze/core/utils/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
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
              signOut(context);
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

              // Delete user function
              if (confirm == true) {
                final user = Supabase.instance.client.auth.currentUser;

                if (user != null) {
                  print('Deleting user with ID: ${user.id}');

                  final response = await http.delete(
                    Uri.parse(
                      'https://xnlydvwnpnbbzduagtzb.supabase.co/functions/v1/delete-user',
                    ),
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode({'userId': user.id}),
                  );

                  if (response.statusCode == 200) {
                    // Sign out the user locally
                    await Supabase.instance.client.auth.signOut();
                  }
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
