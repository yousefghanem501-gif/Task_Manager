import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class DoneTasks extends StatefulWidget {
  const DoneTasks({super.key});

  @override
  State<DoneTasks> createState() => _DoneTasksState();
}

class _DoneTasksState extends State<DoneTasks> {
  static const Color _brand = Color(0xFF1565C0);

  final Box doneTask = Hive.box("done_task");
  final Box myTask = Hive.box("my_task");

  Future<void> _restoreTask(dynamic key) async {
    final task = doneTask.get(key);
    final activeKey = await myTask.add(task);
    await doneTask.delete(key);
    if (!mounted) return;
    setState(() {});

    _showUndo('Moved back to your tasks', () async {
      await doneTask.put(key, task);
      await myTask.delete(activeKey);
      if (mounted) setState(() {});
    });
  }

  Future<void> _deleteTask(dynamic key) async {
    final task = doneTask.get(key);
    await doneTask.delete(key);
    if (!mounted) return;
    setState(() {});

    _showUndo('Task deleted', () async {
      await doneTask.put(key, task);
      if (mounted) setState(() {});
    });
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear completed tasks?'),
        content: Text(
          'This permanently deletes ${doneTask.length} '
              '${doneTask.length == 1 ? 'task' : 'tasks'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await doneTask.clear();
    if (mounted) setState(() {});
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
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          _buildHeader(textTheme),
          Expanded(
            child: doneTask.isEmpty
                ? _buildEmptyState(textTheme)
                : _buildTaskList(textTheme),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(TextTheme textTheme) {
    final count = doneTask.length;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: _brand,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const BackButton(color: Colors.white),
                const Spacer(),
                if (count > 0)
                  TextButton.icon(
                    onPressed: _clearAll,
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    icon: const Icon(Icons.delete_sweep_outlined),
                    label: const Text('Clear all'),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Done tasks',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    count == 0
                        ? 'Nothing completed yet'
                        : '$count ${count == 1 ? 'task' : 'tasks'} completed',
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _brand.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.task_alt, size: 48, color: _brand),
            ),
            const SizedBox(height: 20),
            Text(
              'No completed tasks',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'Tasks you tick off will show up here.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(TextTheme textTheme) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: doneTask.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final key = doneTask.keyAt(index);
        final task = doneTask.getAt(index) as Map;
        final title = task['title']?.toString() ?? '';
        final description = task['description']?.toString() ?? '';

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            leading: Tooltip(
              message: 'Move back to tasks',
              child: Checkbox(
                value: true,
                shape: const CircleBorder(),
                activeColor: _brand,
                onChanged: (_) => _restoreTask(key),
              ),
            ),
            title: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
                decoration: TextDecoration.lineThrough,
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
                  color: Colors.grey.shade500,
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