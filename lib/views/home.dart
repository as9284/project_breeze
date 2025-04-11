import 'dart:async';
import 'dart:ui';
import 'package:breeze/core/utils/task_functions.dart';
import 'package:breeze/views/task_page.dart';
import 'package:flutter/material.dart';

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

  // Function to open a new task page with the corresponding data
  void _openTaskPage(Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TaskDetailPage(
              taskId: task['id'],
              title: task['title'],
              onTaskCompleted: _reloadTasks,
            ),
      ),
    );
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Breeze",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, "/settings");
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchTodos(),
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
                  bottom: 90,
                  left: 10,
                  right: 10,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final task = filtered[index];
                  return InkWell(
                    onTap: () => _openTaskPage(task),
                    borderRadius: BorderRadius.circular(8),
                    child: ListTile(
                      trailing: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.check),
                      ),
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
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    // With dynamic colors like this:
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.black.withValues(alpha: 0.5)
                              : const Color.fromRGBO(245, 250, 252, 0.8),
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
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  color:
                      isDark
                          ? Colors.black.withValues(alpha: 0.5)
                          : const Color.fromRGBO(245, 250, 252, 0.8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
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
                        onPressed:
                            () => {addTask(_taskController), setState(() {})},
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
