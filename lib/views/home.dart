import 'dart:async';
import 'package:breeze/core/widgets/add_task_bar.dart';
import 'package:breeze/core/widgets/search_bar.dart';
import 'package:breeze/core/widgets/task_list_tab.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;
  String _searchQuery = '';

  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _taskFocusNode = FocusNode();

  Future<void> _reloadTasks() async {
    setState(() {});
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Breeze",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          actions: [
            IconButton(
              onPressed: () => Navigator.pushNamed(context, "/settings"),
              icon: const Icon(Icons.settings),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Tasks'), Tab(text: 'Completed')],
          ),
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                TaskListTab(
                  showCompleted: false,
                  searchQuery: _searchQuery,
                  onReload: _reloadTasks,
                ),
                TaskListTab(
                  showCompleted: true,
                  searchQuery: _searchQuery,
                  onReload: _reloadTasks,
                ),
              ],
            ),
            SearchBarWidget(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onChanged: _onSearchChanged,
              isDark: isDark,
            ),
            AddTaskBar(
              controller: _taskController,
              focusNode: _taskFocusNode,
              onTaskAdded: _reloadTasks,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}
