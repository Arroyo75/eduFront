import 'package:flutter/material.dart';
import '../../models/technology.dart';
import '../../services/progress.dart';

class TechnologyHeader extends StatelessWidget {
  final Technology technology;
  final ProgressService? progressService;

  const TechnologyHeader({
    Key? key,
    required this.technology,
    this.progressService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //calculate progress
    final actualProgressPercentage = progressService != null
        ? technology.getActualProgressPercentage(progressService!)
        : technology.progressPercentage;

    final actualCompletedSections = progressService != null
        ? technology.getActualCompletedSections(progressService!)
        : technology.completedSections;

    return SafeArea(
      child: Container(
        height: 200, //fixed height
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    technology.icon,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        technology.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        technology.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _buildStatCard(
                  '$actualCompletedSections/${technology.totalSections}',
                  'Sections',
                  Icons.book,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  '${actualProgressPercentage.toInt()}%',
                  'Complete',
                  Icons.trending_up,
                ),
                const SizedBox(width: 12),
                _buildStatCard(
                  technology.totalEstimatedTime.inHours > 0
                      ? '${technology.totalEstimatedTime.inHours}h'
                      : '${technology.totalEstimatedTime.inMinutes}m',
                  'Duration',
                  Icons.schedule,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(height: 3),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}