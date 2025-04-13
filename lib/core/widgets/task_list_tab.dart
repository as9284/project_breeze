import 'package:flutter/material.dart';
import 'package:breeze/core/utils/task_functions.dart';
import 'package:breeze/views/task_page.dart';

class TaskListTab extends StatelessWidget {
  final bool showCompleted;
  final String searchQuery;
  final Function onReload;

  const TaskListTab({
    super.key,
    required this.showCompleted,
    required this.searchQuery,
    required this.onReload,
  });

  void _openTaskPage(BuildContext context, Map<String, dynamic> task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TaskDetailPage(
              taskId: task['id'],
              title: task['title'],
              onTaskCompleted: () => onReload(),
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchTodos(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final todos = snapshot.data ?? [];

        final filtered =
            todos
                .where(
                  (task) =>
                      (task['is_complete'] ?? false) == showCompleted &&
                      task['title'].toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                )
                .toList();

        if (filtered.isEmpty) {
          return Center(
            child: Text(
              showCompleted ? "No completed tasks yet." : "No tasks found.",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          );
        }

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
            final textStyle = TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
              decoration: showCompleted ? TextDecoration.lineThrough : null,
            );

            return Opacity(
              opacity: showCompleted ? 0.6 : 1.0,
              child: FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 30,
                  ),
                ),
                onPressed: () => _openTaskPage(context, task),
                child: Text(task['title'].toUpperCase(), style: textStyle),
              ),
            );
          },
          separatorBuilder: (_, __) => const SizedBox(height: 15),
        );
      },
    );
  }
}
