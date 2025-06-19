import 'package:flutter/material.dart';
import '../models/quiz.dart';
import '../models/technology.dart';
import '../models/section.dart';

class QuizResultScreen extends StatefulWidget {
  final Technology technology;
  final Section section;
  final Quiz quiz;
  final QuizResult result;

  const QuizResultScreen({
    Key? key,
    required this.technology,
    required this.section,
    required this.quiz,
    required this.result,
  }) : super(key: key);

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreAnimationController;
  late AnimationController _listAnimationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();

    _scoreAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0,
      end: widget.result.percentage / 100,
    ).animate(CurvedAnimation(
      parent: _scoreAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _scoreAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _listAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _scoreAnimationController.dispose();
    _listAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Results'),
        backgroundColor: widget.technology.gradientColors.first,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
          ),
        ],
      ),
      body: Container(
        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              //score
              _buildScoreSection(isDarkMode),

              const SizedBox(height: 32),

              //summary
              _buildSummarySection(isDarkMode),

              const SizedBox(height: 32),

              //details
              _buildDetailedResults(isDarkMode),

              const SizedBox(height: 32),

              //buttons
              _buildActionButtons(isDarkMode),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreSection(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: widget.result.passed
            ? (isDarkMode ? Colors.green.shade900 : Colors.green.shade50)
            : (isDarkMode ? Colors.red.shade900 : Colors.red.shade50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.result.passed ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: AnimatedBuilder(
              animation: _scoreAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: _scoreAnimation.value,
                        strokeWidth: 8,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.result.passed ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.result.score}/${widget.result.totalQuestions}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          '${widget.result.percentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.result.passed ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.result.passed ? Icons.celebration : Icons.refresh,
                color: widget.result.passed ? Colors.green : Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(
                widget.result.passed ? 'Congratulations!' : 'Keep Learning!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            widget.result.passed
                ? 'You passed the Flexbox test! 🎉'
                : 'Review the material and try again. You need ${widget.quiz.passingScore}+ correct answers.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Correct',
            '${widget.result.score}',
            Colors.green,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Incorrect',
            '${widget.result.totalQuestions - widget.result.score}',
            Colors.red,
            isDarkMode,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Time',
            _formatDuration(widget.result.timeTaken),
            widget.technology.gradientColors.first,
            isDarkMode,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDarkMode ? Colors.white60 : Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedResults(bool isDarkMode) {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Results',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),

            const SizedBox(height: 16),

            ...widget.result.questionResults.asMap().entries.map((entry) {
              final index = entry.key;
              final questionResult = entry.value;

              final animationDelay = index * 0.1;
              final animation = CurvedAnimation(
                parent: _listAnimationController,
                curve: Interval(
                  animationDelay,
                  (animationDelay + 0.3).clamp(0.0, 1.0),
                  curve: Curves.easeOut,
                ),
              );

              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: _buildQuestionResultCard(questionResult, index + 1, isDarkMode),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _buildQuestionResultCard(QuestionResult questionResult, int questionNumber, bool isDarkMode) {
    final question = questionResult.question;
    final isCorrect = questionResult.isCorrect;
    final selectedAnswer = questionResult.selectedAnswerIndex != null
        ? question.answers[questionResult.selectedAnswerIndex!]
        : null;
    final correctAnswer = question.correctAnswer;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? Colors.green
              : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCorrect ? Colors.green : Colors.red,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Question $questionNumber',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          //text
          Text(
            question.question,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            ),
          ),

          const SizedBox(height: 12),

          //answer
          if (selectedAnswer != null) ...[
            _buildAnswerRow(
              'Your Answer:',
              selectedAnswer.text,
              isCorrect ? Colors.green : Colors.red,
              isDarkMode,
            ),
            const SizedBox(height: 8),
          ],

          //correct answer (if wrong)
          if (!isCorrect) ...[
            _buildAnswerRow(
              'Correct Answer:',
              correctAnswer.text,
              Colors.green,
              isDarkMode,
            ),
            const SizedBox(height: 8),
          ],

          //explanation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: widget.technology.gradientColors.first,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question.explanation,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDarkMode ? Colors.white60 : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerRow(String label, String answer, Color color, bool isDarkMode) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            answer,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Column(
      children: [
        if (!widget.result.passed) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _retakeQuiz(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.refresh),
                  SizedBox(width: 8),
                  Text('Retake Quiz'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _backToSections(),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.technology.gradientColors.first,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.arrow_back),
                const SizedBox(width: 8),
                Text(widget.result.passed ? 'Continue Learning' : 'Back to Sections'),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _reviewLessons(),
            style: OutlinedButton.styleFrom(
              foregroundColor: isDarkMode ? Colors.white : Colors.black87,
              side: BorderSide(
                color: isDarkMode ? Colors.white70 : Colors.black54,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.school),
                SizedBox(width: 8),
                Text('Review Lessons'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes}m ${seconds}s';
  }

  void _retakeQuiz() {
    Navigator.pop(context);
  }

  void _backToSections() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _reviewLessons() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }
}