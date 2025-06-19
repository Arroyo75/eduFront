import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class LessonSlideshow extends StatefulWidget {
  final Lesson lesson;
  final List<Color> technologyColors;
  final VoidCallback onLessonComplete;

  const LessonSlideshow({
    Key? key,
    required this.lesson,
    required this.technologyColors,
    required this.onLessonComplete,
  }) : super(key: key);

  @override
  State<LessonSlideshow> createState() => _LessonSlideshowState();
}

class _LessonSlideshowState extends State<LessonSlideshow> {
  late PageController _pageController;
  int currentSlide = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentSlide = index;
                });
              },
              itemCount: widget.lesson.slides.length,
              itemBuilder: (context, index) {
                final slide = widget.lesson.slides[index];
                return _buildSlide(slide, isDarkMode);
              },
            ),
          ),

          //slide indicators and nav
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                //indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.lesson.slides.length,
                        (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentSlide
                            ? widget.technologyColors.first
                            : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                //nav buttons
                Row(
                  children: [
                    if (currentSlide > 0) ...[
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousSlide,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                            side: BorderSide(
                              color: isDarkMode ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          child: const Text('Previous'),
                        ),
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _nextSlide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.technologyColors.first,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          currentSlide < widget.lesson.slides.length - 1
                              ? 'Next Slide'
                              : 'Finish Lesson',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //building slide itself
  Widget _buildSlide(LessonSlide slide, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            slide.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),

          const SizedBox(height: 20),

          //content
          _buildFormattedContent(slide.content, isDarkMode),

          const SizedBox(height: 24),

          //code example (if available)
          if (slide.codeExample != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.code,
                        color: widget.technologyColors.first,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Code Example',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.codeExample!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 14,
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

  Widget _buildFormattedContent(String content, bool isDarkMode) {
    final lines = content.split('\n');
    List<Widget> widgets = [];

    for (String line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      //bullet point formatting
      if (line.startsWith('•')) {
        widgets.add(_buildBulletPoint(line, isDarkMode));
      }
      //section header formatting
      else if (line.trim().length < 50 &&
          !line.contains('.') &&
          !line.contains(',') &&
          lines.indexOf(line) < lines.length - 1 &&
          lines[lines.indexOf(line) + 1].startsWith('•')) {
        widgets.add(_buildSectionHeader(line, isDarkMode));
      }
      //regular text
      else {
        widgets.add(_buildParagraph(line, isDarkMode));
      }

      widgets.add(const SizedBox(height: 8));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildBulletPoint(String line, bool isDarkMode) {
    final text = line.substring(1).trim(); // Remove bullet point
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextStyle(
              fontSize: 16,
              color: widget.technologyColors.first,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String line, bool isDarkMode) {
    return Text(
      line.trim(),
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDarkMode ? Colors.white : Colors.black87,
        height: 1.4,
      ),
    );
  }

  Widget _buildParagraph(String line, bool isDarkMode) {
    return Text(
      line,
      style: TextStyle(
        fontSize: 16,
        height: 1.6,
        color: isDarkMode ? Colors.white70 : Colors.black87,
      ),
    );
  }

  void _previousSlide() {
    if (currentSlide > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextSlide() {
    if (currentSlide < widget.lesson.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onLessonComplete();
    }
  }
}