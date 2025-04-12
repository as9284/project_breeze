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
  bool _isEditing = false;

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

  Future<void> _saveEdits() async {
    if (_task == null) return;

    await Supabase.instance.client
        .from('todos')
        .update({
          'title': _titleController.text,
          'description': _descriptionController.text,
        })
        .eq('id', _task!['id']);

    setState(() {
      _isEditing = false;
    });

    widget.onTaskCompleted();
  }

  void _cancelEdits() {
    setState(() {
      _titleController.text = _task?['title'] ?? '';
      _descriptionController.text = _task?['description'] ?? '';
      _isEditing = false;
    });
  }

  void _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Delete Task"),
            content: Text(
              'Are you sure you want to permanently delete "${widget.title}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () async {
                  await _deleteTask();
                  Navigator.pop(context, true);
                },
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true) {
      Navigator.pop(context);
    }
  }

  Future<void> _deleteTask() async {
    if (_task == null) return;

    await Supabase.instance.client
        .from('todos')
        .delete()
        .eq('id', _task!['id']);
    widget.onTaskCompleted();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body:
          _task == null
              ? const Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Task Title",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _isEditing
                                  ? TextField(
                                    controller: _titleController,
                                    decoration: InputDecoration(
                                      hintText: "Enter task title...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                  : Text(
                                    _titleController.text,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                              const SizedBox(height: 30),
                              const Text(
                                "Task Description",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              _isEditing
                                  ? TextField(
                                    controller: _descriptionController,
                                    maxLines: 5,
                                    decoration: InputDecoration(
                                      hintText: "Add more details here...",
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  )
                                  : Text(
                                    _descriptionController.text,
                                    style: const TextStyle(fontSize: 15),
                                  ),
                              const SizedBox(height: 30),
                              const Spacer(), // This will push the buttons to the bottom
                              Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Buttons (conditional rendering based on completion)
                                    if (_task!['is_complete'] == true)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Show only the delete button if the task is complete
                                          ElevatedButton.icon(
                                            onPressed:
                                                () => _confirmDelete(context),
                                            icon: const Icon(Icons.delete),
                                            label: const Text("Delete"),
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 30,
                                                    vertical: 20,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Show the Edit and Complete buttons if the task is not complete
                                          if (_isEditing)
                                            ElevatedButton.icon(
                                              onPressed: _saveEdits,
                                              icon: const Icon(Icons.save),
                                              label: const Text("Save"),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 20,
                                                    ),
                                              ),
                                            ),
                                          if (_isEditing)
                                            const SizedBox(width: 20),
                                          if (_isEditing)
                                            TextButton(
                                              onPressed: _cancelEdits,
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 20,
                                                    ),
                                              ),
                                              child: const Text("Cancel"),
                                            ),
                                          if (!_isEditing)
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                setState(() {
                                                  _isEditing = true;
                                                });
                                              },
                                              icon: const Icon(Icons.edit),
                                              label: const Text("Edit"),
                                              style: ElevatedButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 20,
                                                    ),
                                              ),
                                            ),
                                          if (!_isEditing)
                                            const SizedBox(width: 20),
                                          if (!_isEditing)
                                            FilledButton.icon(
                                              onPressed:
                                                  () => completeTask(
                                                    context,
                                                    widget,
                                                    _task,
                                                  ),
                                              icon: const Icon(
                                                Icons.check_circle,
                                              ),
                                              label: const Text("Complete"),
                                              style: FilledButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 30,
                                                      vertical: 20,
                                                    ),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
