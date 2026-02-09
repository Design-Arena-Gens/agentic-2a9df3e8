import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _todayTasks = [];
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<Task> get tasks => _tasks;
  List<Task> get todayTasks => _todayTasks;
  bool get isLoading => _isLoading;
  DateTime get selectedDate => _selectedDate;

  List<Task> get incompleteTasks =>
      _tasks.where((task) => !task.isCompleted).toList();

  List<Task> get completedTasks =>
      _tasks.where((task) => task.isCompleted).toList();

  TaskProvider() {
    loadTasks();
    loadTodayTasks();
  }

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  Future<void> loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await DatabaseService.instance.getAllTasks();
      _tasks = _expandRecurringTasks(_tasks);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadTodayTasks() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      _todayTasks = await DatabaseService.instance.getTasksByDate(startOfDay);
      _todayTasks = _expandRecurringTasksForDate(_todayTasks, startOfDay);
    } catch (e) {
      debugPrint('Error loading today tasks: $e');
    }
    notifyListeners();
  }

  Future<List<Task>> getTasksForDate(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final tasks = await DatabaseService.instance.getTasksByDate(startOfDay);
    return _expandRecurringTasksForDate(tasks, startOfDay);
  }

  Future<List<Task>> getTasksForDateRange(DateTime start, DateTime end) async {
    final tasks = await DatabaseService.instance.getTasksByDateRange(start, end);
    return _expandRecurringTasks(tasks);
  }

  List<Task> _expandRecurringTasks(List<Task> tasks) {
    final expandedTasks = <Task>[];
    final now = DateTime.now();
    final futureLimit = now.add(Duration(days: 365));

    for (var task in tasks) {
      if (task.recurrence == null) {
        expandedTasks.add(task);
      } else {
        expandedTasks.addAll(_generateRecurringInstances(task, now, futureLimit));
      }
    }

    return expandedTasks;
  }

  List<Task> _expandRecurringTasksForDate(List<Task> tasks, DateTime date) {
    final expandedTasks = <Task>[];

    for (var task in tasks) {
      if (task.recurrence == null) {
        expandedTasks.add(task);
      } else {
        final instances = _generateRecurringInstancesForDate(task, date);
        expandedTasks.addAll(instances);
      }
    }

    return expandedTasks;
  }

  List<Task> _generateRecurringInstances(Task task, DateTime start, DateTime end) {
    final instances = <Task>[];
    var currentDate = task.dueDate;

    while (currentDate.isBefore(end)) {
      if (currentDate.isAfter(start) || _isSameDay(currentDate, start)) {
        if (task.recurrenceEndDate == null ||
            currentDate.isBefore(task.recurrenceEndDate!) ||
            _isSameDay(currentDate, task.recurrenceEndDate!)) {
          instances.add(task.copyWith(dueDate: currentDate));
        }
      }

      switch (task.recurrence) {
        case 'daily':
          currentDate = currentDate.add(Duration(days: 1));
          break;
        case 'weekly':
          currentDate = currentDate.add(Duration(days: 7));
          break;
        case 'monthly':
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
          );
          break;
        default:
          return instances;
      }
    }

    return instances;
  }

  List<Task> _generateRecurringInstancesForDate(Task task, DateTime date) {
    if (task.recurrence == null) return [task];

    var currentDate = task.dueDate;
    final endDate = task.recurrenceEndDate ?? date.add(Duration(days: 365));

    while (currentDate.isBefore(date) || _isSameDay(currentDate, date)) {
      if (_isSameDay(currentDate, date)) {
        if (task.recurrenceEndDate == null ||
            currentDate.isBefore(task.recurrenceEndDate!) ||
            _isSameDay(currentDate, task.recurrenceEndDate!)) {
          return [task.copyWith(dueDate: currentDate)];
        }
      }

      if (currentDate.isAfter(endDate)) break;

      switch (task.recurrence) {
        case 'daily':
          currentDate = currentDate.add(Duration(days: 1));
          break;
        case 'weekly':
          currentDate = currentDate.add(Duration(days: 7));
          break;
        case 'monthly':
          currentDate = DateTime(
            currentDate.year,
            currentDate.month + 1,
            currentDate.day,
          );
          break;
        default:
          return [];
      }
    }

    return [];
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> addTask(Task task) async {
    try {
      final newTask = await DatabaseService.instance.createTask(task);
      _tasks.add(newTask);
      await loadTodayTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await DatabaseService.instance.updateTask(task);
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = task;
      }
      await loadTodayTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating task: $e');
    }
  }

  Future<void> toggleTaskCompletion(Task task) async {
    try {
      final updatedTask = task.copyWith(
        isCompleted: !task.isCompleted,
        completedAt: !task.isCompleted ? DateTime.now() : null,
      );
      await updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error toggling task: $e');
    }
  }

  Future<void> deleteTask(int id) async {
    try {
      await DatabaseService.instance.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      await loadTodayTasks();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting task: $e');
    }
  }

  Future<Map<String, int>> getStatistics() async {
    return await DatabaseService.instance.getTaskStatistics();
  }
}
