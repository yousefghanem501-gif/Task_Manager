import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_4/screens/add_task.dart';

import 'done_tasks.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const Color _brand = Color(0xFF1565C0);

  final Box box = Hive.box("my_task");
  final Box doneBox = Hive.box("done_task");


  final Set<dynamic> _completing = {};

  String name = "";

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() => name = prefs.getString('username') ?? '');
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    final part = hour < 12
        ? 'Good morning'
        : hour < 18
        ? 'Good afternoon'
        : 'Good evening';
    return name.isEmpty ? part : '$part, $name';
  }

  Future<void> _completeTask(dynamic key) async {
    if (_completing.contains(key)) return;

    setState(() => _completing.add(key));
    await Future.delayed(const Duration(milliseconds: 300));

    _completing.remove(key);
    if (!mounted || !box.containsKey(key)) return;

    final task = box.get(key);
    final doneKey = await doneBox.add(task);
    await box.delete(key);
    if (!mounted) return;
    setState(() {});

    _showUndo('Task completed', () async {
      await box.put(key, task);
      await doneBox.delete(doneKey);
      if (mounted) setState(() {});
    });
  }

  Future<void> _deleteTask(dynamic key) async {
    final task = box.get(key);
    await box.delete(key);
    if (!mounted) return;
    setState(() {});

    _showUndo('Task deleted', () async {
      await box.put(key, task);
      if (mounted) setState(() {});
    });
  }

  void _showUndo(String message, VoidCallback onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: 'Undo', onPressed: onUndo),
        ),
      );
  }

  Future<void> _openAddTask() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTask()),
    );
    if (mounted) setState(() {});
  }

  Future<void> _openDoneTasks() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DoneTasks()),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddTask,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
      ),
      body: Column(
        children: [
          _buildHeader(textTheme),
          Expanded(
            child: box.isEmpty
                ? _buildEmptyState(textTheme)
                : _buildTaskList(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    final todo = box.length;
    final done = doneBox.length;
    final total = todo + done;

    final subtitle = todo == 0
        ? 'Nothing left to do'
        : 'You have $todo ${todo == 1 ? 'task' : 'tasks'} left';

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _brand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 0, 12, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Completed tasks',
                  onPressed: _openDoneTasks,
                  color: Colors.white,
                  icon: Badge(
                    isLabelVisible: done > 0,
                    label: Text('$done'),
                    child: const Icon(Icons.task_alt, size: 28),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            if (total > 0) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: done / total,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.25),
                        valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$done of $total done',
                      style: textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    final allDone = doneBox.isNotEmpty;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/empty.json", width: 240, height: 240),
            const SizedBox(height: 8),
            Text(
              allDone ? "You're all caught up" : 'No tasks yet',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              allDone
                  ? 'Add another task when something comes up.'
                  : 'Tap Add task to create your first one.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TextTheme textTheme) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
      itemCount: box.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final key = box.keyAt(index);
        final task = box.getAt(index) as Map;
        final title = task["title"]?.toString() ?? '';
        final description = task["description"]?.toString() ?? '';
        final isCompleting = _completing.contains(key);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Checkbox(
              value: isCompleting,
              shape: const CircleBorder(),
              activeColor: _brand,
              side: BorderSide(color: Colors.grey.shade400, width: 1.5),
              onChanged: (_) => _completeTask(key),
            ),
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isCompleting ? Colors.grey : null,
                decoration: isCompleting ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: description.isEmpty
                ? null
                : Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            trailing: IconButton(
              tooltip: 'Delete task',
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              onPressed: () => _deleteTask(key),
            ),
          ),
        );
      },
    );
  }
}
