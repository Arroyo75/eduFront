import 'package:flutter/material.dart';
import '../../models/section.dart';
import '../../services/progress.dart';
import '../../services/settings.dart';

class SectionCard extends StatefulWidget {
  final Section section;
  final List<Color> technologyColors;
  final VoidCallback onTap; //main lesson
  final VoidCallback onTestTap; //quiz
  final String technologyId;
  final Key? refreshKey;
  final VoidCallback? onProgressChanged;
  final Function(Section)? onSectionCompleted;

  const SectionCard({
    Key? key,
    required this.section,
    required this.technologyColors,
    required this.onTap,
    required this.onTestTap,
    required this.technologyId,
    this.refreshKey,
    this.onProgressChanged,
    this.onSectionCompleted
  }) : super(key: key);

  @override
  State<SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<SectionCard> {
  final ProgressService _progressService = ProgressService();
  final SettingsService _settingsService = SettingsService();
  int actualCompletedLessons = 0;
  bool actualTestCompleted = false;
  bool _isLoading = true;
  bool _hasRealProgress = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  @override
  void didUpdateWidget(SectionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshKey != oldWidget.refreshKey) {
      print('Key change refresh for section card');
      _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    await _progressService.init();
    await _settingsService.init();

    //real progress
    final realCompletedLessons = _progressService.getSectionProgress(widget.technologyId, widget.section.id);
    final realTestCompleted = _progressService.isSectionTestCompleted(widget.technologyId, widget.section.id);

    //is it missing?
    _hasRealProgress = realCompletedLessons > 0 || realTestCompleted;

    int finalCompletedLessons;
    bool finalTestCompleted;

    if (_hasRealProgress) {
      //if exists use real progress
      finalCompletedLessons = realCompletedLessons;
      finalTestCompleted = realTestCompleted;
    } else {
      //if not fallback to sample data
      finalCompletedLessons = widget.section.completedLessons;
      finalTestCompleted = widget.section.finalTestCompleted;
    }

    if (mounted) {
      setState(() {
        actualCompletedLessons = finalCompletedLessons;
        actualTestCompleted = finalTestCompleted;
        _isLoading = false;
      });
    }
  }

  Future<void> _debugCompleteSection() async { //skips section

    //directly set the section progress to the total number of lessons
    await _progressService.setSectionProgress(
      widget.technologyId,
      widget.section.id,
      widget.section.totalLessons,
    );

    //completed test
    await _progressService.markSectionTestCompleted(
      widget.technologyId,
      widget.section.id,
      true, // passed = true
    );

    //reload progress to reflect changes
    await _loadProgress();

    //notify parent that progress changed (this will update technology progress)
    widget.onProgressChanged?.call();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ ${widget.section.title}: ${widget.section.totalLessons}/${widget.section.totalLessons} lessons + test completed!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
    widget.onProgressChanged?.call();
    widget.onSectionCompleted?.call(widget.section);

  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final progressPercentage = widget.section.totalLessons > 0
        ? (actualCompletedLessons / widget.section.totalLessons * 100).round()
        : 0;
    final lessonsCompleted = actualCompletedLessons >= widget.section.totalLessons;
    final sectionCompleted = lessonsCompleted && actualTestCompleted;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: widget.section.isLocked ? 2 : 6,
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            children: [
              // Main Section Content
              InkWell(
                onTap: widget.section.isLocked ? null : widget.onTap,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: widget.section.isLocked
                        ? LinearGradient(
                      colors: [Colors.grey.shade300, Colors.grey.shade400],
                    )
                        : LinearGradient(
                      colors: [
                        widget.technologyColors.first.withOpacity(0.1),
                        widget.technologyColors.last.withOpacity(0.05),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Section Icon
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: widget.section.isLocked
                                  ? Colors.grey.shade500
                                  : widget.technologyColors.first,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              widget.section.icon,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),

                          //section info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.section.title,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: widget.section.isLocked
                                              ? Colors.grey.shade600
                                              : (isDarkMode ? Colors.white : Colors.black87),
                                        ),
                                      ),
                                    ),
                                    //debug complete button
                                    if (_settingsService.debugMode && !sectionCompleted) ...[
                                      IconButton(
                                        onPressed: _debugCompleteSection,
                                        icon: const Icon(Icons.fast_forward),
                                        tooltip: 'DEBUG: Complete Section',
                                        color: Colors.orange,
                                        iconSize: 20,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    // Show data source indicator in debug mode
                                    if (!_hasRealProgress && actualCompletedLessons > 0) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'DEMO',
                                          style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                    ],
                                    if (widget.section.isLocked) ...[
                                      Icon(
                                        Icons.lock,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ] else if (sectionCompleted) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Completed',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.section.description,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: widget.section.isLocked
                                        ? Colors.grey.shade500
                                        : (isDarkMode ? Colors.white60 : Colors.grey.shade700),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      //progress and stats
                      _isLoading
                          ? const SizedBox(
                        height: 20,
                        child: Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                          : Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '$actualCompletedLessons/${widget.section.totalLessons} lessons',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: widget.section.isLocked
                                            ? Colors.grey.shade500
                                            : (isDarkMode ? Colors.white60 : Colors.grey.shade600),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      widget.section.estimatedTimeText,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: widget.section.isLocked
                                            ? Colors.grey.shade500
                                            : (isDarkMode ? Colors.white60 : Colors.grey.shade600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progressPercentage / 100,
                                  backgroundColor: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.section.isLocked
                                        ? Colors.grey.shade500
                                        : widget.technologyColors.first,
                                  ),
                                  minHeight: 4,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$progressPercentage%',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: widget.section.isLocked
                                  ? Colors.grey.shade500
                                  : widget.technologyColors.first,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //final test
              Container(
                decoration: BoxDecoration(
                  color: lessonsCompleted
                      ? (isDarkMode ? Colors.grey.shade700 : widget.technologyColors.first.withOpacity(0.05))
                      : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100),
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: InkWell(
                  onTap: lessonsCompleted ? widget.onTestTap : null,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          actualTestCompleted
                              ? Icons.check_circle
                              : lessonsCompleted
                              ? Icons.quiz
                              : Icons.lock,
                          color: actualTestCompleted
                              ? Colors.green
                              : lessonsCompleted
                              ? widget.technologyColors.first
                              : Colors.grey.shade500,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Final Section Test',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: lessonsCompleted
                                  ? (isDarkMode ? Colors.white : Colors.black87)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                        if (actualTestCompleted) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Passed',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ] else if (lessonsCompleted) ...[
                          Icon(
                            Icons.arrow_forward_ios,
                            color: widget.technologyColors.first,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}