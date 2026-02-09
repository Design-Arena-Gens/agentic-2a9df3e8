import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('taskflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const boolType = 'INTEGER NOT NULL';

    await db.execute('''
      CREATE TABLE tasks (
        id $idType,
        title $textType,
        description $textTypeNullable,
        dueDate $textType,
        dueTime $textTypeNullable,
        priority $intType,
        isCompleted $boolType,
        category $textTypeNullable,
        recurrence $textTypeNullable,
        recurrenceEndDate $textTypeNullable,
        createdAt $textType,
        completedAt $textTypeNullable
      )
    ''');
  }

  Future<Task> createTask(Task task) async {
    final db = await instance.database;
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  Future<Task?> getTask(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> getAllTasks() async {
    final db = await instance.database;
    const orderBy = 'dueDate ASC, priority DESC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> getTasksByDate(DateTime date) async {
    final db = await instance.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final result = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'priority DESC, dueTime ASC',
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> getTasksByDateRange(DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'dueDate >= ? AND dueDate <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'dueDate ASC, priority DESC',
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> getIncompleteTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [0],
      orderBy: 'dueDate ASC, priority DESC',
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<List<Task>> getCompletedTasks() async {
    final db = await instance.database;
    final result = await db.query(
      'tasks',
      where: 'isCompleted = ?',
      whereArgs: [1],
      orderBy: 'completedAt DESC',
    );

    return result.map((json) => Task.fromMap(json)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await instance.database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> deleteTask(int id) async {
    final db = await instance.database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, int>> getTaskStatistics() async {
    final db = await instance.database;

    final totalResult = await db.rawQuery('SELECT COUNT(*) as count FROM tasks');
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 1'
    );
    final pendingResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM tasks WHERE isCompleted = 0'
    );

    return {
      'total': totalResult.first['count'] as int,
      'completed': completedResult.first['count'] as int,
      'pending': pendingResult.first['count'] as int,
    };
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
