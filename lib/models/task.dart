class Task {
  final int? id;
  final String title;
  final String? description;
  final DateTime dueDate;
  final DateTime? dueTime;
  final int priority; // 0: Low, 1: Medium, 2: High
  final bool isCompleted;
  final String? category;
  final String? recurrence; // null, 'daily', 'weekly', 'monthly'
  final DateTime? recurrenceEndDate;
  final DateTime createdAt;
  final DateTime? completedAt;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    this.dueTime,
    this.priority = 1,
    this.isCompleted = false,
    this.category,
    this.recurrence,
    this.recurrenceEndDate,
    required this.createdAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'dueTime': dueTime?.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted ? 1 : 0,
      'category': category,
      'recurrence': recurrence,
      'recurrenceEndDate': recurrenceEndDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      dueTime: map['dueTime'] != null ? DateTime.parse(map['dueTime']) : null,
      priority: map['priority'],
      isCompleted: map['isCompleted'] == 1,
      category: map['category'],
      recurrence: map['recurrence'],
      recurrenceEndDate: map['recurrenceEndDate'] != null
          ? DateTime.parse(map['recurrenceEndDate'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? dueTime,
    int? priority,
    bool? isCompleted,
    String? category,
    String? recurrence,
    DateTime? recurrenceEndDate,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      dueTime: dueTime ?? this.dueTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      category: category ?? this.category,
      recurrence: recurrence ?? this.recurrence,
      recurrenceEndDate: recurrenceEndDate ?? this.recurrenceEndDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  String get priorityLabel {
    switch (priority) {
      case 2:
        return 'High';
      case 1:
        return 'Medium';
      case 0:
        return 'Low';
      default:
        return 'Medium';
    }
  }
}
