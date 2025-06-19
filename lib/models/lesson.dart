class Lesson {
  final String id;
  final String title;
  final String description;
  final LessonType type;
  final List<LessonSlide> slides;
  final Duration estimatedTime;
  final bool isCompleted;
  final bool isLocked;
  final List<String> prerequisites;

  Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.slides,
    required this.estimatedTime,
    this.isCompleted = false,
    this.isLocked = false,
    this.prerequisites = const [],
  });
}

enum LessonType { slideshow, interactive, quiz }

class LessonSlide {
  final String title;
  final String content;
  final String? codeExample;
  final FlexboxDemo? demo;
  final SlideType type;

  LessonSlide({
    required this.title,
    required this.content,
    this.codeExample,
    this.demo,
    this.type = SlideType.content,
  });
}

enum SlideType { content, demo, code, summary }

class FlexboxDemo {
  final String property;
  final List<String> values;
  final String defaultValue;
  final String description;

  FlexboxDemo({
    required this.property,
    required this.values,
    required this.defaultValue,
    required this.description,
  });
}