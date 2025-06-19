import 'package:flutter/material.dart';

class Section {
  final String id;
  final String title;
  final String description;
  final int totalLessons;
  final int completedLessons;
  final bool finalTestCompleted;
  final bool isLocked;
  final List<String> prerequisites;
  final IconData icon;
  final Duration estimatedTime;

  Section({
    required this.id,
    required this.title,
    required this.description,
    required this.totalLessons,
    this.completedLessons = 0,
    this.finalTestCompleted = false,
    this.isLocked = false,
    this.prerequisites = const [],
    required this.icon,
    required this.estimatedTime,
  });

  double get progressPercentage {
    if (totalLessons == 0) return 0.0;
    return (completedLessons / totalLessons) * 100;
  }

  bool get isCompleted => completedLessons >= totalLessons && finalTestCompleted;
  bool get lessonsCompleted => completedLessons >= totalLessons;

  String get progressText => '$completedLessons/$totalLessons lessons';

  String get estimatedTimeText {
    final hours = estimatedTime.inHours;
    final minutes = estimatedTime.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}