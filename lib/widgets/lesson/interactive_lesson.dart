import 'package:flutter/material.dart';
import '../../models/lesson.dart';

class InteractiveLesson extends StatefulWidget {
  final Lesson lesson;
  final List<Color> technologyColors;
  final VoidCallback onLessonComplete;
  final VoidCallback? onPreviousLesson;

  const InteractiveLesson({
    Key? key,
    required this.lesson,
    required this.technologyColors,
    required this.onLessonComplete,
    this.onPreviousLesson,
  }) : super(key: key);

  @override
  State<InteractiveLesson> createState() => _InteractiveLessonState();
}

class _InteractiveLessonState extends State<InteractiveLesson> {
  String selectedValue = 'flex-start';

  final List<String> justifyContentValues = [
    'flex-start',
    'flex-end',
    'center',
    'space-between',
    'space-around',
    'space-evenly'
  ];

  final Map<String, String> valueDescriptions = {
    'flex-start': 'Items are packed at the start of the container. This is the default behavior.',
    'flex-end': 'Items are packed at the end of the container.',
    'center': 'Items are centered in the container - perfect for centering content!',
    'space-between': 'Items are spread out with equal space between them. First and last items touch the edges.',
    'space-around': 'Items have equal space around them. Space at edges is half the space between items.',
    'space-evenly': 'Items are distributed with equal space everywhere - including at the edges.',
  };

  final Map<String, String> useCases = {
    'flex-start': 'Default layout, reading order, lists',
    'flex-end': 'Right-aligned content, RTL layouts',
    'center': 'Centered logos, hero content, modals',
    'space-between': 'Navigation bars, button groups',
    'space-around': 'Card grids, icon sets',
    'space-evenly': 'Evenly spaced buttons, form fields',
  };

  Set<String> triedValues = {};

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Container(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //header
                  _buildHeader(isDarkMode),
                  const SizedBox(height: 24),

                  //interactive demo
                  _buildInteractiveDemo(isDarkMode),
                  const SizedBox(height: 24),

                  //current value explanation
                  _buildValueExplanation(isDarkMode),
                  const SizedBox(height: 24),

                  //progress and completion
                  _buildProgress(isDarkMode),
                ],
              ),
            ),
          ),
        ),

        //nav buttons
        _buildNavigationButtons(isDarkMode),
      ],
    );
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.touch_app,
              color: widget.technologyColors.first,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Interactive Lab',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Master justify-content by experimenting with different values. Click the buttons below to see how they affect the layout!',
          style: TextStyle(
            fontSize: 16,
            color: isDarkMode ? Colors.white70 : Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInteractiveDemo(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: widget.technologyColors.first.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Text(
                  'justify-content: ',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
                Text(
                  selectedValue,
                  style: TextStyle(
                    color: widget.technologyColors.first,
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  ';',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          //selector buttons
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: justifyContentValues.map((value) {
              final isSelected = value == selectedValue;
              final hasBeenTried = triedValues.contains(value);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedValue = value;
                    triedValues.add(value);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.technologyColors.first
                        : hasBeenTried
                        ? Colors.green.shade100
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? widget.technologyColors.first
                          : hasBeenTried
                          ? Colors.green
                          : widget.technologyColors.first,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasBeenTried && !isSelected) ...[
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        value,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : hasBeenTried
                              ? Colors.green.shade700
                              : widget.technologyColors.first,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          //flexbox demo
          Container(
            width: double.infinity,
            height: 120,
            padding: const EdgeInsets.all(8), // Reduced padding
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child: _buildFlexboxDemo(),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexboxDemo() {
    MainAxisAlignment alignment;

    switch (selectedValue) {
      case 'flex-start':
        alignment = MainAxisAlignment.start;
        break;
      case 'flex-end':
        alignment = MainAxisAlignment.end;
        break;
      case 'center':
        alignment = MainAxisAlignment.center;
        break;
      case 'space-between':
        alignment = MainAxisAlignment.spaceBetween;
        break;
      case 'space-around':
        alignment = MainAxisAlignment.spaceAround;
        break;
      case 'space-evenly':
        alignment = MainAxisAlignment.spaceEvenly;
        break;
      default:
        alignment = MainAxisAlignment.start;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: constraints.maxWidth,
            child: Row(
              mainAxisAlignment: alignment,
              children: [
                _buildFlexItem('1', Colors.red.shade300),
                _buildFlexItem('2', Colors.green.shade300),
                _buildFlexItem('3', Colors.blue.shade300),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFlexItem(String text, Color color) {
    return Container(
      width: 36, // Slightly smaller to prevent overflow
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 2), // Small margin
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildValueExplanation(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: widget.technologyColors.first,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                selectedValue,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: widget.technologyColors.first,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            valueDescriptions[selectedValue] ?? '',
            style: TextStyle(
              fontSize: 15,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                'Best for: ',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white70 : Colors.black87,
                ),
              ),
              Expanded(
                child: Text(
                  useCases[selectedValue] ?? '',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgress(bool isDarkMode) {
    final progress = triedValues.length / justifyContentValues.length;
    final isComplete = triedValues.length == justifyContentValues.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete
            ? (isDarkMode ? Colors.green.shade900 : Colors.green.shade50)
            : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isComplete
              ? Colors.green.shade300
              : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isComplete ? Icons.check_circle : Icons.track_changes,
                color: isComplete ? Colors.green : widget.technologyColors.first,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isComplete ? 'Lesson Complete!' : 'Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isComplete
                      ? Colors.green
                      : widget.technologyColors.first,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress bar
          LinearProgressIndicator(
            value: progress,
            backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(
              isComplete ? Colors.green : widget.technologyColors.first,
            ),
            minHeight: 6,
          ),

          const SizedBox(height: 8),

          Text(
            '${triedValues.length}/${justifyContentValues.length} values explored',
            style: TextStyle(
              fontSize: 14,
              color: isComplete
                  ? Colors.green.shade700
                  : (isDarkMode ? Colors.white60 : Colors.grey.shade600),
            ),
          ),

          if (isComplete) ...[
            const SizedBox(height: 12),
            Text(
              '🎉 Excellent work! You\'ve tried all justify-content values and understand how each one works. You\'re ready to use Flexbox in real projects!',
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDarkMode) {
    final isComplete = triedValues.length == justifyContentValues.length;

    return Container(
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
      child: Row(
        children: [
          if (widget.onPreviousLesson != null) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: widget.onPreviousLesson,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                  side: BorderSide(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                child: const Text('Previous Lesson'),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: ElevatedButton(
              onPressed: isComplete ? widget.onLessonComplete : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isComplete
                    ? widget.technologyColors.first
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isComplete) ...[
                    const Icon(Icons.check, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text('Complete'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}