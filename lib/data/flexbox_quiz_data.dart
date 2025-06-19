import '../models/quiz.dart';

class FlexboxQuizData {
  static Quiz getFlexboxFinalTest() {
    return Quiz(
      id: 'flexbox-final-test',
      title: 'Flexbox Mastery Test',
      description: 'Test your knowledge of CSS Flexbox concepts, properties, and practical applications.',
      passingScore: 7,
      questions: [
        QuizQuestion(
          id: 'q1',
          question: 'What CSS property is used to create a flex container?',
          answers: [
            QuizAnswer(text: 'display: flex'),
            QuizAnswer(text: 'flex-container: true'),
            QuizAnswer(text: 'layout: flexbox'),
            QuizAnswer(text: 'flex: container'),
          ],
          correctAnswerIndex: 0,
          explanation: 'The display: flex property creates a flex container, making its direct children flex items.',
          codeExample: '.container {\n  display: flex;\n}',
        ),

        QuizQuestion(
          id: 'q2',
          question: 'Which justify-content value distributes items with equal space between them, but no space at the edges?',
          answers: [
            QuizAnswer(text: 'space-around'),
            QuizAnswer(text: 'space-between'),
            QuizAnswer(text: 'space-evenly'),
            QuizAnswer(text: 'center'),
          ],
          correctAnswerIndex: 1,
          explanation: 'space-between places equal space between items, with the first and last items touching the container edges.',
        ),

        QuizQuestion(
          id: 'q3',
          question: 'In Flexbox, what is the main axis by default?',
          answers: [
            QuizAnswer(text: 'Vertical (top to bottom)'),
            QuizAnswer(text: 'Horizontal (left to right)'),
            QuizAnswer(text: 'Diagonal'),
            QuizAnswer(text: 'It depends on the content'),
          ],
          correctAnswerIndex: 1,
          explanation: 'By default, the main axis runs horizontally from left to right. This can be changed with flex-direction.',
        ),

        QuizQuestion(
          id: 'q4',
          question: 'Which property controls the direction of flex items?',
          answers: [
            QuizAnswer(text: 'flex-flow'),
            QuizAnswer(text: 'flex-direction'),
            QuizAnswer(text: 'justify-content'),
            QuizAnswer(text: 'align-items'),
          ],
          correctAnswerIndex: 1,
          explanation: 'flex-direction controls whether flex items flow in rows or columns, and their direction.',
          codeExample: '.container {\n  flex-direction: column;\n}',
        ),

        QuizQuestion(
          id: 'q5',
          question: 'What is the difference between space-around and space-evenly?',
          answers: [
            QuizAnswer(text: 'There is no difference'),
            QuizAnswer(text: 'space-around puts half-size space at edges, space-evenly puts full-size space everywhere'),
            QuizAnswer(text: 'space-around centers items, space-evenly spreads them'),
            QuizAnswer(text: 'space-around works vertically, space-evenly works horizontally'),
          ],
          correctAnswerIndex: 1,
          explanation: 'space-around gives items equal space around them (half at edges), while space-evenly distributes equal space everywhere including edges.',
        ),

        QuizQuestion(
          id: 'q6',
          question: 'Which scenario is Flexbox BEST suited for?',
          answers: [
            QuizAnswer(text: 'Complex grid layouts with many rows and columns'),
            QuizAnswer(text: 'Navigation bars with centered logo and spread menu items'),
            QuizAnswer(text: 'Magazine-style multi-column text layouts'),
            QuizAnswer(text: 'Fixed positioning of elements'),
          ],
          correctAnswerIndex: 1,
          explanation: 'Flexbox excels at one-dimensional layouts like navigation bars, where you need flexible alignment and space distribution.',
        ),

        QuizQuestion(
          id: 'q7',
          question: 'What happens to direct children of a flex container?',
          answers: [
            QuizAnswer(text: 'Nothing changes'),
            QuizAnswer(text: 'They become flex items automatically'),
            QuizAnswer(text: 'They become flex containers themselves'),
            QuizAnswer(text: 'They lose all their CSS properties'),
          ],
          correctAnswerIndex: 1,
          explanation: 'Direct children of a flex container automatically become flex items and can be controlled by flex properties.',
        ),

        QuizQuestion(
          id: 'q8',
          question: 'Which CSS code would center content both horizontally and vertically?',
          answers: [
            QuizAnswer(text: 'justify-content: center;\nalign-items: center;'),
            QuizAnswer(text: 'text-align: center;\nvertical-align: middle;'),
            QuizAnswer(text: 'margin: auto;\npadding: auto;'),
            QuizAnswer(text: 'position: center;\ndisplay: center;'),
          ],
          correctAnswerIndex: 0,
          explanation: 'justify-content: center centers along the main axis, align-items: center centers along the cross axis.',
          codeExample: '.container {\n  display: flex;\n  justify-content: center;\n  align-items: center;\n}',
        ),

        QuizQuestion(
          id: 'q9',
          question: 'Before Flexbox, which methods were commonly used for layouts (and were more complex)?',
          answers: [
            QuizAnswer(text: 'CSS Grid and Subgrid'),
            QuizAnswer(text: 'Floats, positioning, and tables'),
            QuizAnswer(text: 'JavaScript and jQuery'),
            QuizAnswer(text: 'HTML5 and CSS4'),
          ],
          correctAnswerIndex: 1,
          explanation: 'Before Flexbox, developers relied on floats, positioning, and table layouts, which were much more complex and limited.',
        ),

        QuizQuestion(
          id: 'q10',
          question: 'What is the main advantage of using Flexbox for responsive design?',
          answers: [
            QuizAnswer(text: 'It only works on mobile devices'),
            QuizAnswer(text: 'Elements automatically adapt to available space'),
            QuizAnswer(text: 'It requires less CSS code than other methods'),
            QuizAnswer(text: 'It works without any CSS properties'),
          ],
          correctAnswerIndex: 1,
          explanation: 'Flexbox items can grow, shrink, and adapt to available space automatically, making responsive design much easier.',
        ),
      ],
    );
  }
}