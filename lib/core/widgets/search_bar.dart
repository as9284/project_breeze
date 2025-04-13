import 'dart:ui';
import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool isDark;

  const SearchBarWidget({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color:
                    isDark
                        ? Colors.black.withValues(alpha: 0.01)
                        : const Color.fromRGBO(245, 250, 252, 0.8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                focusNode: focusNode,
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color.fromRGBO(245, 250, 252, 0),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
