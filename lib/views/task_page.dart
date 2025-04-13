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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LabeledTextField(
                                  label: "Task Title",
                                  controller: _titleController,
                                  isEditing: _isEditing,
                                  hintText: "Enter task title...",
                                ),
                                const SizedBox(height: 30),
                                LabeledTextField(
                                  label: "Task Description",
                                  controller: _descriptionController,
                                  isEditing: _isEditing,
                                  hintText: "Add more details here...",
                                  maxLines: 5,
                                ),
                                const Spacer(),
                                Center(
                                  child: TaskActionButtons(
                                    isComplete: _task!['is_complete'] == true,
                                    isEditing: _isEditing,
                                    onSave: _saveEdits,
                                    onCancel: _cancelEdits,
                                    onEdit:
                                        () => setState(() => _isEditing = true),
                                    onComplete:
                                        () => completeTask(
                                          context,
                                          widget,
                                          _task,
                                        ),
                                    onDelete: () => _confirmDelete(context),
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
      ),
    );
  }
}
