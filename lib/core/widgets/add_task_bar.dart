import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:breeze/core/utils/task_functions.dart';

class AddTaskBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onTaskAdded;
  final bool isDark;

  const AddTaskBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onTaskAdded,
    required this.isDark,
  });

  Future<void> _handleSubmit(BuildContext context) async {
    await addTask(controller);
    onTaskAdded();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color:
                isDark
                    ? Colors.black.withValues(alpha: 0.01)
                    : const Color.fromRGBO(245, 250, 252, 0.8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    onSubmitted: (_) => _handleSubmit(context),
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
                FilledButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                  onPressed: () => _handleSubmit(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
