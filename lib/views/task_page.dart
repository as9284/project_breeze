import 'package:breeze/core/utils/task_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import "../core/widgets/task_widgets.dart";

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
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _loadTask();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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

    final updatedTitle = _titleController.text;
    final updatedDescription = _descriptionController.text;

    await Supabase.instance.client
        .from('todos')
        .update({'title': updatedTitle, 'description': updatedDescription})
        .eq('id', _task!['id']);

    // Update local task cache
    setState(() {
      _task!['title'] = updatedTitle;
      _task!['description'] = updatedDescription;
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
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          Navigator.pop(context);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Task",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actionsPadding: EdgeInsets.only(right: 20),
          actions: [
            if (_task != null && _task!['is_complete'] == true)
              IconButton(
                icon: const Icon(Icons.delete),
                tooltip: "Delete",
                onPressed: () => _confirmDelete(context),
              )
            else if (_isEditing) ...[
              IconButton(
                icon: const Icon(Icons.save),
                tooltip: "Save",
                onPressed: _saveEdits,
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.cancel),
                tooltip: "Cancel",
                onPressed: _cancelEdits,
              ),
            ] else ...[
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: "Edit",
                onPressed: () => setState(() => _isEditing = true),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.check_circle),
                tooltip: "Mark Complete",
                onPressed: () => completeTask(context, widget, _task),
              ),
            ],
          ],
        ),

        body:
            _task == null
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: IntrinsicHeight(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LabeledTextField(
                                    label: "Task Title",
                                    controller: _titleController,
                                    isEditing: _isEditing,
                                    hintText: "Enter task title...",
                                  ),
                                  const SizedBox(height: 10),
                                  LabeledTextField(
                                    label: "Task Description",
                                    controller: _descriptionController,
                                    isEditing: _isEditing,
                                    hintText: "Add a description...",
                                    maxLines: 17,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
      ),
    );
  }
}
