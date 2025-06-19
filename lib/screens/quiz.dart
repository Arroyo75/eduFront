import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/technology.dart';
import '../models/section.dart';
import '../data/flexbox_quiz_data.dart';
import '../services/progress.dart';
import 'quiz_result.dart';

class QuizScreen extends StatefulWidget {
  final Technology technology;
  final Section section;

  const QuizScreen({
    Key? key,
    required this.technology,
    required this.section,
  }) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late Quiz quiz;
  late PageController _pageController;
  int currentQuestionIndex = 0;
  List<int?> selectedAnswers = [];
  DateTime? startTime;
  bool isQuizCompleted = false;
  final ProgressService _progressService = ProgressService();

  @override
  void initState() {
    super.initState();
    _loadQuiz();
    _pageController = PageController();
    startTime = DateTime.now();
    _progressService.init();
  }

  void _loadQuiz() {

    //mvp only flexbox
    if (widget.section.id == 'css-flexbox') {
      quiz = FlexboxQuizData.getFlexboxFinalTest();
    } else {
      //placeholder
      quiz = Quiz(
        id: 'placeholder',
        title: 'Coming Soon',
        description: 'This quiz is under development',
        questions: [],
      );
    }

    selectedAnswers = List.filled(quiz.questions.length, null);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('${widget.section.title} - Test'),
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
                'Quiz coming soon!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.title),
        backgroundColor: widget.technology.gradientColors.first,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${currentQuestionIndex + 1}/${quiz.totalQuestions}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / quiz.totalQuestions,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.technology.gradientColors.first,
              ),
            ),

            //content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentQuestionIndex = index;
                  });
                },
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(quiz.questions[index], index, isDarkMode);
                },
              ),
            ),

            _buildNavigationButtons(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionPage(QuizQuestion question, int index, bool isDarkMode) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: widget.technology.gradientColors.first,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            question.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDarkMode ? Colors.white : Colors.black87,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 8),

          //code example (if available)
          if (question.codeExample != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                question.codeExample!,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 14,
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          //answers
          ...question.answers.asMap().entries.map((entry) {
            final answerIndex = entry.key;
            final answer = entry.value;
            final isSelected = selectedAnswers[index] == answerIndex;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedAnswers[index] = answerIndex;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? widget.technology.gradientColors.first.withOpacity(0.1)
                        : (isDarkMode ? Colors.grey.shade800 : Colors.grey.shade50),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? widget.technology.gradientColors.first
                          : (isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? widget.technology.gradientColors.first
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? widget.technology.gradientColors.first
                                : Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                            : null,
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          answer.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isDarkMode) {
    final canGoNext = selectedAnswers[currentQuestionIndex] != null;
    final isLastQuestion = currentQuestionIndex == quiz.questions.length - 1;

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
          if (currentQuestionIndex > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _previousQuestion,
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
              onPressed: canGoNext ? (isLastQuestion ? _finishQuiz : _nextQuestion) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canGoNext
                    ? widget.technology.gradientColors.first
                    : Colors.grey.shade400,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: Text(
                isLastQuestion ? 'Finish Quiz' : 'Next Question',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextQuestion() {
    if (currentQuestionIndex < quiz.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishQuiz() async {
    final endTime = DateTime.now();
    final timeTaken = endTime.difference(startTime!);

    //calc results
    int score = 0;
    List<QuestionResult> questionResults = [];

    for (int i = 0; i < quiz.questions.length; i++) {
      final question = quiz.questions[i];
      final selectedIndex = selectedAnswers[i];
      final isCorrect = selectedIndex == question.correctAnswerIndex;

      if (isCorrect) score++;

      questionResults.add(QuestionResult(
        question: question,
        selectedAnswerIndex: selectedIndex,
        isCorrect: isCorrect,
      ));
    }

    final result = QuizResult(
      score: score,
      totalQuestions: quiz.totalQuestions,
      questionResults: questionResults,
      timeTaken: timeTaken,
      passed: score >= quiz.passingScore,
    );

    await _progressService.markSectionTestCompleted(
      widget.technology.id,
      widget.section.id,
      result.passed,
    );

    await _progressService.submitQuizResult(
      technologyId: widget.technology.id,
      sectionId: widget.section.id,
      score: score,
      totalQuestions: quiz.totalQuestions,
      timeTaken: timeTaken,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuizResultScreen(
          technology: widget.technology,
          section: widget.section,
          quiz: quiz,
          result: result,
        ),
      ),
    );
  }
}