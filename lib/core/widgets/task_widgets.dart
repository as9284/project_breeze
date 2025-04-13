import 'package:flutter/material.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isEditing;
  final int maxLines;
  final String hintText;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
    this.maxLines = 1,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        isEditing
            ? TextField(
              controller: controller,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintText: hintText,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
            : Text(controller.text, style: const TextStyle(fontSize: 15)),
      ],
    );
  }
}

class TaskActionButtons extends StatelessWidget {
  final bool isComplete;
  final bool isEditing;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const TaskActionButtons({
    super.key,
    required this.isComplete,
    required this.isEditing,
    required this.onSave,
    required this.onCancel,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (isComplete) {
      return ElevatedButton.icon(
        onPressed: onDelete,
        icon: const Icon(Icons.delete),
        label: const Text("Delete"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isEditing)
          ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save),
            label: const Text("Save"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
          ),
        if (isEditing) const SizedBox(width: 20),
        if (isEditing)
          TextButton(
            onPressed: onCancel,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
            child: const Text("Cancel"),
          ),
        if (!isEditing)
          ElevatedButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            label: const Text("Edit"),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
          ),
        if (!isEditing) const SizedBox(width: 20),
        if (!isEditing)
          FilledButton.icon(
            onPressed: onComplete,
            icon: const Icon(Icons.check_circle),
            label: const Text("Complete"),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            ),
          ),
      ],
    );
  }
}
