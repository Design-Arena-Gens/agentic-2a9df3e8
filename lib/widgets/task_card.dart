import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';
import '../screens/add_task_screen.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({Key? key, required this.task}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final category = TaskCategory.getByName(task.category);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(task: task),
                ),
              );
            },
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (context) {
              _showDeleteConfirmation(context, taskProvider);
            },
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: task.isCompleted
                ? Colors.green.withOpacity(0.3)
                : Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTaskScreen(task: task),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Checkbox
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    taskProvider.toggleTaskCompletion(task);
                  },
                  shape: const CircleBorder(),
                ),
                const SizedBox(width: 12),

                // Task Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.isCompleted
                              ? Colors.grey[600]
                              : Colors.black87,
                        ),
                      ),

                      // Description
                      if (task.description != null &&
                          task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          task.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Metadata Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          // Time
                          if (task.dueTime != null)
                            _buildChip(
                              icon: Icons.access_time,
                              label: DateFormat('h:mm a')
                                  .format(task.dueTime!),
                              color: Colors.blue,
                            ),

                          // Category
                          if (category != null)
                            _buildChip(
                              icon: category.icon,
                              label: category.name,
                              color: category.color,
                            ),

                          // Recurrence
                          if (task.recurrence != null)
                            _buildChip(
                              icon: Icons.repeat,
                              label: task.recurrence!.toUpperCase(),
                              color: Colors.purple,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Priority Indicator
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getPriorityColor(task.priority),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 2:
        return Colors.red;
      case 1:
        return Colors.orange;
      case 0:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _showDeleteConfirmation(BuildContext context, TaskProvider taskProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              taskProvider.deleteTask(task.id!);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
