class Quiz {
  final String id;
  final String title;
  final String description;
  final List<QuizQuestion> questions;
  final int passingScore; // Out of total questions

  Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.passingScore = 7, // 70% to pass
  });

  int get totalQuestions => questions.length;
  double get passingPercentage => (passingScore / totalQuestions) * 100;
}

class QuizQuestion {
  final String id;
  final String question;
  final List<QuizAnswer> answers;
  final int correctAnswerIndex;
  final String explanation;
  final String? codeExample;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.answers,
    required this.correctAnswerIndex,
    required this.explanation,
    this.codeExample,
  });

  QuizAnswer get correctAnswer => answers[correctAnswerIndex];
}

class QuizAnswer {
  final String text;
  final String? explanation;

  QuizAnswer({
    required this.text,
    this.explanation,
  });
}

class QuizResult {
  final int score;
  final int totalQuestions;
  final List<QuestionResult> questionResults;
  final Duration timeTaken;
  final bool passed;

  QuizResult({
    required this.score,
    required this.totalQuestions,
    required this.questionResults,
    required this.timeTaken,
    required this.passed,
  });

  double get percentage => (score / totalQuestions) * 100;
}

class QuestionResult {
  final QuizQuestion question;
  final int? selectedAnswerIndex;
  final bool isCorrect;

  QuestionResult({
    required this.question,
    this.selectedAnswerIndex,
    required this.isCorrect,
  });
}