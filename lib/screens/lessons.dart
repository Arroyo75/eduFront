import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../models/technology.dart';
import '../models/section.dart';
import '../widgets/lesson/lesson_slideshow.dart';
import '../widgets/lesson/interactive_lesson.dart';
import '../data/flexbox_lessons_data.dart';
import '../services/progress.dart';

class LessonsScreen extends StatefulWidget {
  final Technology technology;
  final Section section;

  const LessonsScreen({
    Key? key,
    required this.technology,
    required this.section,
  }) : super(key: key);

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  late List<Lesson> lessons;
  int currentLessonIndex = 0;
  final ProgressService _progressService = ProgressService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _progressService.init();
    _loadLessons();

    setState(() {
      _isLoading = false;
    });
  }

  void _loadLessons() {
    //for mvp just flexbox
    if (widget.section.id == 'css-flexbox') {
      lessons = FlexboxLessonsData.getLessons();
    } else {
      //placeholder for others
      lessons = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.section.title} - Lessons'),
          backgroundColor: widget.technology.gradientColors.first,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading lessons...',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    if (lessons.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.section.title} - Lessons'),
          backgroundColor: widget.technology.gradientColors.first,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Lessons coming soon!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final currentLesson = lessons[currentLessonIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentLesson.title),
        backgroundColor: widget.technology.gradientColors.first,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${currentLessonIndex + 1}/${lessons.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (currentLessonIndex + 1) / lessons.length,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.technology.gradientColors.first,
            ),
          ),

          //content
          Expanded(
            child: _buildLessonContent(currentLesson),
          ),

          //slideshow lesson navigation buttons
          if (currentLesson.type == LessonType.slideshow) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  if (currentLessonIndex > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousLesson,
                        child: const Text('Previous Lesson'),
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextLesson,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.technology.gradientColors.first,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        currentLessonIndex < lessons.length - 1 ? 'Next Lesson' : 'Complete',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonContent(Lesson lesson) {
    switch (lesson.type) {
      case LessonType.slideshow:
        return LessonSlideshow(
          lesson: lesson,
          technologyColors: widget.technology.gradientColors,
          onLessonComplete: _onLessonComplete,
        );
      case LessonType.interactive:
        return InteractiveLesson(
          lesson: lesson,
          technologyColors: widget.technology.gradientColors,
          onLessonComplete: _onLessonComplete,
          onPreviousLesson: currentLessonIndex > 0 ? _previousLesson : null,
        );
      case LessonType.quiz:
        return const Center(child: Text('Quiz lesson coming soon!'));
    }
  }

  void _previousLesson() {
    if (currentLessonIndex > 0) {
      setState(() {
        currentLessonIndex--;
      });
    }
  }

  void _onLessonComplete() async {
    final lessonId = 'lesson_${currentLessonIndex + 1}';

    await _progressService.markLessonCompleted(
      widget.technology.id,
      widget.section.id,
      lessonId,
    );

    _nextLesson();
  }

  void _nextLesson() {
    if (currentLessonIndex < lessons.length - 1) {
      setState(() {
        currentLessonIndex++;
      });
    } else {
      _completeAllLessons();
    }
  }

  void _completeAllLessons() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All lessons completed! You can now take the final test. 🎉'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}