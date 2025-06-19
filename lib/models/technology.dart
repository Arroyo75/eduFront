import 'package:flutter/material.dart';
import 'section.dart';
import '../services/progress.dart';

class Technology {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final List<Section> sections;
  final List<String> prerequisites;
  final bool isLocked;

  Technology({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.sections,
    this.prerequisites = const [],
    this.isLocked = false,
  });

  int get totalSections => sections.length;
  int get completedSections => sections.where((s) => s.isCompleted).length;

  double get progressPercentage {
    if (totalSections == 0) return 0.0;
    return (completedSections / totalSections) * 100;
  }

  bool get isCompleted => completedSections >= totalSections;

  Duration get totalEstimatedTime {
    return sections.fold(
      Duration.zero,
          (total, section) => total + section.estimatedTime,
    );
  }

  double getActualProgressPercentage(ProgressService progressService) {
    if (totalSections == 0) return 0.0;

    int actualCompletedSections = 0;

    for (final section in sections) {
      final actualCompletedLessons = progressService.getSectionProgress(id, section.id);
      final actualTestCompleted = progressService.isSectionTestCompleted(id, section.id);

      if (actualCompletedLessons >= section.totalLessons && actualTestCompleted) {
        actualCompletedSections++;
      }
    }

    return (actualCompletedSections / totalSections) * 100;
  }

  int getActualCompletedSections(ProgressService progressService) {
    int actualCompletedSections = 0;

    for (final section in sections) {
      final actualCompletedLessons = progressService.getSectionProgress(id, section.id);
      final actualTestCompleted = progressService.isSectionTestCompleted(id, section.id);

      if (actualCompletedLessons >= section.totalLessons && actualTestCompleted) {
        actualCompletedSections++;
      }
    }

    return actualCompletedSections;
  }

}