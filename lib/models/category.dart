import 'package:flutter/material.dart';

class TaskCategory {
  final String name;
  final IconData icon;
  final Color color;

  const TaskCategory({
    required this.name,
    required this.icon,
    required this.color,
  });

  static const List<TaskCategory> predefined = [
    TaskCategory(
      name: 'Work',
      icon: Icons.work,
      color: Color(0xFF6366F1),
    ),
    TaskCategory(
      name: 'Personal',
      icon: Icons.person,
      color: Color(0xFF8B5CF6),
    ),
    TaskCategory(
      name: 'Health',
      icon: Icons.favorite,
      color: Color(0xFFEC4899),
    ),
    TaskCategory(
      name: 'Education',
      icon: Icons.school,
      color: Color(0xFF10B981),
    ),
    TaskCategory(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Color(0xFFF59E0B),
    ),
    TaskCategory(
      name: 'Home',
      icon: Icons.home,
      color: Color(0xFF06B6D4),
    ),
  ];

  static TaskCategory? getByName(String? name) {
    if (name == null) return null;
    try {
      return predefined.firstWhere((cat) => cat.name == name);
    } catch (e) {
      return null;
    }
  }
}
