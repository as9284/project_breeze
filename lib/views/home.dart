import 'dart:async';
import 'dart:ui';
import 'package:breeze/core/utils/auth_functions.dart';
import 'package:breeze/views/task_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  // Function to fetch tasks
  Future<List<Map<String, dynamic>>> _fetchTodos() async {
    final response = await Supabase.instance.client
        .from('todos')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // Function to add a new task
  Future<void> _addTask() async {
    final text = _taskController.text.trim();
    if (text.isNotEmpty) {
      final userId = Supabase.instance.client.auth.currentUser?.id;

      await Supabase.instance.client.from('todos').insert({
        'title': text,
        'description': '',
        'is_complete': false,
        'user_id': userId,
      });

      _taskController.clear();
      setState(() {});

      if (!mounted) return;
      FocusScope.of(context).requestFocus(FocusNode());
    }
  }

  Future<void> _deleteTask(String id) async {
    await Supabase.instance.client.from('todos').delete().eq('id', id);
    setState(() {});
  }

  // Function to show a confirmation dialogue
  Future<bool?> _showConfirmDialog(String title) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Are you sure you want to delete "$title"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Function to open a new task page with the corresponding data
  void _openTaskPage(String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TaskDetailPage(title: title, onTaskCompleted: _reloadTasks),
      ),
    );

    FocusScope.of(context).requestFocus(FocusNode());
  }

  // Function to reload the page
  void _reloadTasks() {
    setState(() {});
  }

  // Function to debounce search to prevent API spam
  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Breeze",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              signOut(context);
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchTodos(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final todos = snapshot.data ?? [];
              final filtered =
                  todos
                      .where(
                        (task) => task['title'].toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();

              return ListView.separated(
                padding: const EdgeInsets.only(
                  top: 90,
                  bottom: 80,
                  left: 10,
                  right: 10,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final task = filtered[index];
                  return Dismissible(
                    key: ValueKey(task['id']),
                    confirmDismiss: (_) => _showConfirmDialog(task['title']),
                    onDismissed: (_) => _deleteTask(task['id']),
                    background: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.redAccent,
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: InkWell(
                      onTap: () => _openTaskPage(task['title']),
                      borderRadius: BorderRadius.circular(8),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        tileColor: const Color.fromARGB(255, 0, 103, 118),
                        minVerticalPadding: 20,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder:
                    (context, index) => const SizedBox(height: 10),
              );
            },
          ),

          // Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(245, 250, 252, 0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      focusNode: FocusNode(),
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color.fromRGBO(245, 250, 252, 0),
                      ),
                      onChanged: _onSearchChanged, // Use the debounce method
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Task Input
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color: const Color.fromRGBO(245, 250, 252, 0.8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          focusNode: FocusNode(),
                          controller: _taskController,
                          decoration: InputDecoration(
                            hintText: "Add a task...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color.fromRGBO(245, 250, 252, 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTask,
                        child: const Text("Add"),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
