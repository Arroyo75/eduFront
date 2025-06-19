import '../models/lesson.dart';

class FlexboxLessonsData {
  static List<Lesson> getLessons() {
    return [
      // Lesson 1: Slideshow Introduction
      Lesson(
        id: 'flexbox-intro',
        title: 'Introduction to Flexbox',
        description: 'Learn what Flexbox is and when to use it',
        type: LessonType.slideshow,
        estimatedTime: const Duration(minutes: 6),
        slides: [
          LessonSlide(
            title: 'What is Flexbox?',
            content: '''Flexbox (Flexible Box Layout) is a powerful CSS layout method that makes it easy to arrange elements in rows or columns.

Think of it as a smart way to distribute space and align items in a container, even when their size is unknown or dynamic.

Before Flexbox, creating flexible layouts required complex CSS tricks with floats, positioning, and tables. Flexbox simplifies this dramatically!''',
            type: SlideType.content,
          ),

          LessonSlide(
            title: 'Why Use Flexbox?',
            content: '''Flexbox solves many common layout problems:

• Centering elements - Both horizontally and vertically
• Equal height columns - No more height hacks
• Space distribution - Automatically fill available space
• Responsive design - Elements adapt to screen size
• Order control - Change visual order without changing HTML

It's perfect for navigation bars, card layouts, forms, and any component where you need flexible alignment.''',
            type: SlideType.content,
          ),

          LessonSlide(
            title: 'Flex Container & Items',
            content: '''Flexbox works with two main concepts:

Flex Container (Parent)
The element with display: flex - this creates the flex context.

Flex Items (Children)
Direct children of the flex container - these are the elements that will be arranged.

The container controls how its children are laid out, while items can have individual properties to control their behavior.''',
            codeExample: '''.container {
  display: flex; /* Makes this a flex container */
}

.item {
  /* These become flex items automatically */
  flex: 1; /* Grows to fill space */
}''',
            type: SlideType.code,
          ),

          LessonSlide(
            title: 'Main Axis vs Cross Axis',
            content: '''Flexbox uses two axes:

Main Axis - The primary direction of flex items
• Default: horizontal (left to right)
• Controlled by flex-direction

Cross Axis - Perpendicular to the main axis
• Default: vertical (top to bottom)
• Automatically determined

Understanding these axes is crucial because many flexbox properties work along one axis or the other.''',
            type: SlideType.content,
          ),

          LessonSlide(
            title: 'justify-content Property',
            content: '''The justify-content property is one of the most useful flexbox properties. It controls how flex items are distributed along the main axis.

Common values:
• flex-start - Items packed at the start
• flex-end - Items packed at the end  
• center - Items centered
• space-between - Items spread with space between them
• space-around - Items with equal space around them
• space-evenly - Items with equal space everywhere

In the next lesson, you'll get to experiment with all these values interactively!''',
            codeExample: '''.container {
  display: flex;
  justify-content: center; /* Centers all items */
}

.navbar {
  display: flex;
  justify-content: space-between; /* Logo left, menu right */
}''',
            type: SlideType.code,
          ),

          LessonSlide(
            title: 'Ready for Hands-On Practice?',
            content: '''Great job! You've learned the fundamentals of Flexbox:

What you now know:
• What Flexbox is and why it's useful
• Flex containers vs flex items
• Main axis and cross axis concepts
• The justify-content property basics

What's next:
In the next lesson, you'll get hands-on experience with justify-content. You'll be able to click different values and see exactly how they affect the layout in real-time.

This interactive approach will help you understand not just what each value does, but when to use each one!''',
            type: SlideType.summary,
          ),
        ],
      ),

      // Lesson 2: Interactive justify-content
      Lesson(
        id: 'flexbox-justify-content',
        title: 'Master justify-content',
        description: 'Interactive lesson to master the justify-content property',
        type: LessonType.interactive,
        estimatedTime: const Duration(minutes: 10),
        slides: [], // Interactive lessons don't use slides
      ),
    ];
  }
}