import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Complete task function
Future<void> completeTask(context, widget, task) async {
  final confirm = await showDialog<bool>(
    context: context,
    builder:
        (_) => AlertDialog(
          title: const Text("Complete Task"),
          content: Text(
            'Are you sure you want to mark "${widget.title}" as complete and remove it?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Complete",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
  );

  if (confirm == true && task != null) {
    await Supabase.instance.client.from('todos').delete().eq('id', task!['id']);

    widget.onTaskCompleted();
    Navigator.pop(context);
  }
}

// Function to fetch tasks
Future<List<Map<String, dynamic>>> fetchTodos() async {
  final response = await Supabase.instance.client
      .from('todos')
      .select()
      .order('created_at', ascending: false);

  return List<Map<String, dynamic>>.from(response);
}

// Function to add a new task
Future<void> addTask(taskController) async {
  final text = taskController.text.trim();
  if (text.isNotEmpty) {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    await Supabase.instance.client.from('todos').insert({
      'title': text,
      'description': '',
      'is_complete': false,
      'user_id': userId,
    });

    taskController.clear();
  }
}