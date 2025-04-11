import 'package:breeze/core/utils/task_functions.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskDetailPage extends StatefulWidget {
  final VoidCallback onTaskCompleted;
  final String taskId;
  final String title;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.title,
    required this.onTaskCompleted,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  Map<String, dynamic>? _task;

  @override
  void initState() {
    super.initState();
    _loadTask();
  }

  Future<void> _loadTask() async {
    final result =
        await Supabase.instance.client
            .from('todos')
            .select()
            .eq('id', widget.taskId)
            .maybeSingle();

    if (result != null) {
      setState(() {
        _task = result;
        _titleController.text = result['title'] ?? '';
        _descriptionController.text = result['description'] ?? '';
      });
    }
  }

  Future<void> _updateTaskTitle() async {
    if (_task == null) return;

    await Supabase.instance.client
        .from('todos')
        .update({'title': _titleController.text})
        .eq('id', _task!['id']);

    widget.onTaskCompleted();
  }

  Future<void> _updateDescription() async {
    if (_task == null) return;

    await Supabase.instance.client
        .from('todos')
        .update({'description': _descriptionController.text})
        .eq('id', _task!['id']);

    widget.onTaskCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _task?['title'] ?? "", // Display task title in AppBar
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              _task == null
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Section
                      const Text(
                        "Task Title",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: "Enter task title...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => _updateTaskTitle(),
                      ),
                      const SizedBox(height: 30),

                      // Description Section
                      const Text(
                        "Task Description",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Add more details here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => _updateDescription(),
                      ),
                      const SizedBox(height: 40),

                      // Complete Task Button
                      Center(
                        child: FilledButton.icon(
                          onPressed: () => completeTask(context, widget, _task),
                          icon: const Icon(Icons.check_circle, size: 20),
                          label: const Text(
                            "Complete Task",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 30,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
