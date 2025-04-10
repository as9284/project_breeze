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
        _descriptionController.text = result['description'] ?? '';
      });
    }
  }

  Future<void> _updateDescription() async {
    if (_task == null) return;

    await Supabase.instance.client
        .from('todos')
        .update({'description': _descriptionController.text})
        .eq('id', _task!['id']);
  }

  Future<void> _completeTask() async {
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

    if (confirm == true && _task != null) {
      await Supabase.instance.client
          .from('todos')
          .delete()
          .eq('id', _task!['id']);

      widget.onTaskCompleted();

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_task?['title'] ?? "Task")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:
            _task == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                    const SizedBox(height: 30),
                    FilledButton.icon(
                      onPressed: _completeTask,
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Complete Task"),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
