import 'package:flutter/material.dart';
import '../../models/technology.dart';
import '../../services/progress.dart';

class TechnologyCard extends StatelessWidget {
  final Technology technology;
  final VoidCallback onTap;
  final ProgressService? progressService; // Add this parameter

  const TechnologyCard({
    Key? key,
    required this.technology,
    required this.onTap,
    this.progressService, // Add this parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //calculate progress
    final progressPercentage = progressService != null
        ? technology.getActualProgressPercentage(progressService!)
        : technology.progressPercentage;

    final completedSections = progressService != null
        ? technology.getActualCompletedSections(progressService!)
        : technology.completedSections;

    final isLocked = technology.isLocked;
    final isCompleted = progressService != null
        ? completedSections >= technology.totalSections
        : technology.isCompleted;

    return RepaintBoundary( //avoid unnecessary repaints
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          elevation: isLocked ? 2 : 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: InkWell(
            onTap: isLocked ? null : onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: isLocked
                      ? [Colors.grey.shade400, Colors.grey.shade500]
                      : technology.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Technology Icon
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            technology.icon,
                            size: 30,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Technology Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      technology.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  if (isLocked) ...[
                                    const Icon(
                                      Icons.lock,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                technology.description,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    //display prerequisites
                    if (technology.prerequisites.isNotEmpty) ...[
                      Text(
                        'Prerequisites: ${technology.prerequisites.join(', ')}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    //progress info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$completedSections/${technology.totalSections} sections completed',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${progressPercentage.toInt()}%',
                              style: const TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              technology.totalEstimatedTime.inHours > 0
                                  ? '${technology.totalEstimatedTime.inHours}h'
                                  : '${technology.totalEstimatedTime.inMinutes}m',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white60,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    //progress bar
                    LinearProgressIndicator(
                      value: progressPercentage / 100,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 6,
                    ),

                    //completion badge
                    if (isCompleted) ...[
                      const SizedBox(height: 12),
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Completed',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}