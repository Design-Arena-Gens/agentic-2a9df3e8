import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../models/category.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;

  const AddTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  TimeOfDay? _selectedTime;
  int _priority = 1;
  String? _selectedCategory;
  String? _recurrence;
  DateTime? _recurrenceEndDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedDate = widget.task!.dueDate;
      _selectedTime = widget.task!.dueTime != null
          ? TimeOfDay.fromDateTime(widget.task!.dueTime!)
          : null;
      _priority = widget.task!.priority;
      _selectedCategory = widget.task!.category;
      _recurrence = widget.task!.recurrence;
      _recurrenceEndDate = widget.task!.recurrenceEndDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectRecurrenceEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _recurrenceEndDate ?? _selectedDate.add(const Duration(days: 30)),
      firstDate: _selectedDate,
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _recurrenceEndDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);

      DateTime? dueTime;
      if (_selectedTime != null) {
        dueTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        );
      }

      final task = Task(
        id: widget.task?.id,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        dueDate: _selectedDate,
        dueTime: dueTime,
        priority: _priority,
        category: _selectedCategory,
        recurrence: _recurrence,
        recurrenceEndDate: _recurrenceEndDate,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
      );

      if (widget.task == null) {
        taskProvider.addTask(task);
      } else {
        taskProvider.updateTask(task);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'New Task'),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: const Text(
              'Save',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a task title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            const Text(
              'Due Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectDate,
            ),
            const SizedBox(height: 16),
            ListTile(
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              leading: const Icon(Icons.access_time),
              title: Text(_selectedTime != null
                  ? _selectedTime!.format(context)
                  : 'Set Time (Optional)'),
              trailing: _selectedTime != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _selectedTime = null;
                        });
                      },
                    )
                  : const Icon(Icons.chevron_right),
              onTap: _selectTime,
            ),
            const SizedBox(height: 24),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(
                  value: 0,
                  label: Text('Low'),
                  icon: Icon(Icons.flag, color: Colors.green),
                ),
                ButtonSegment(
                  value: 1,
                  label: Text('Medium'),
                  icon: Icon(Icons.flag, color: Colors.orange),
                ),
                ButtonSegment(
                  value: 2,
                  label: Text('High'),
                  icon: Icon(Icons.flag, color: Colors.red),
                ),
              ],
              selected: {_priority},
              onSelectionChanged: (Set<int> newSelection) {
                setState(() {
                  _priority = newSelection.first;
                });
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'Category',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TaskCategory.predefined.map((category) {
                final isSelected = _selectedCategory == category.name;
                return FilterChip(
                  selected: isSelected,
                  label: Text(category.name),
                  avatar: Icon(
                    category.icon,
                    size: 18,
                    color: isSelected ? Colors.white : category.color,
                  ),
                  selectedColor: category.color,
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = selected ? category.name : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recurrence',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              value: _recurrence,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.repeat),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Does not repeat')),
                DropdownMenuItem(value: 'daily', child: Text('Daily')),
                DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (value) {
                setState(() {
                  _recurrence = value;
                  if (value == null) {
                    _recurrenceEndDate = null;
                  }
                });
              },
            ),
            if (_recurrence != null) ...[
              const SizedBox(height: 16),
              ListTile(
                tileColor: Colors.grey[100],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                leading: const Icon(Icons.event_repeat),
                title: Text(_recurrenceEndDate != null
                    ? 'Ends on ${DateFormat('MMM d, yyyy').format(_recurrenceEndDate!)}'
                    : 'Set End Date (Optional)'),
                trailing: _recurrenceEndDate != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _recurrenceEndDate = null;
                          });
                        },
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _selectRecurrenceEndDate,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
