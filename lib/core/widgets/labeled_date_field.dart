import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LabeledDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final bool isEditing;
  final VoidCallback onTap;

  const LabeledDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.isEditing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        selectedDate != null
            ? DateFormat.yMMMEd().add_jm().format(selectedDate!)
            : 'No due date set';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing)
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        GestureDetector(
          onTap: isEditing ? onTap : null,
          child: AbsorbPointer(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: dateText,
                suffixIcon: isEditing ? const Icon(Icons.calendar_today) : null,
                enabledBorder:
                    isEditing
                        ? null
                        : const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                        ),
              ),
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}
