import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadTasksForMonth();
  }

  Future<void> _loadTasksForMonth() async {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    final start = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final end = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    final tasks = await taskProvider.getTasksForDateRange(start, end);

    final Map<DateTime, List<Task>> tasksByDate = {};
    for (var task in tasks) {
      final date = DateTime(
        task.dueDate.year,
        task.dueDate.month,
        task.dueDate.day,
      );
      if (tasksByDate[date] == null) {
        tasksByDate[date] = [];
      }
      tasksByDate[date]!.add(task);
    }

    setState(() {
      _tasksByDate = tasksByDate;
    });
  }

  List<Task> _getTasksForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _tasksByDate[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calendar',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
              _loadTasksForMonth();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                _loadTasksForMonth();
              },
              eventLoader: _getTasksForDay,
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                markerDecoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 3,
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: true,
                titleCentered: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  _selectedDay != null
                      ? DateFormat('MMMM d, yyyy').format(_selectedDay!)
                      : 'Select a date',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<Task>>(
              future: _selectedDay != null
                  ? taskProvider.getTasksForDate(_selectedDay!)
                  : Future.value([]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final tasks = snapshot.data ?? [];
                final incompleteTasks =
                    tasks.where((t) => !t.isCompleted).toList();
                final completedTasks =
                    tasks.where((t) => t.isCompleted).toList();

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tasks for this day',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (incompleteTasks.isNotEmpty) ...[
                      ...incompleteTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(task: task),
                          )),
                      const SizedBox(height: 12),
                    ],
                    if (completedTasks.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Completed (${completedTasks.length})',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ...completedTasks.map((task) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TaskCard(task: task),
                          )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
