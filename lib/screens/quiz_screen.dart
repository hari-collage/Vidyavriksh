import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _correctAnswers = 0;
  bool _quizFinished = false;
  bool _pointsAdded = false;

  void _selectAnswer(int selectedIndex) {
    if (_quizFinished) return;

    final question = DataService.quizQuestions[_currentIndex];
    if (selectedIndex == question.correctAnswerIndex) {
      _correctAnswers++;
    }

    if (_currentIndex < DataService.quizQuestions.length - 1) {
      setState(() {
        _currentIndex++;
      });
    } else {
      setState(() {
        _quizFinished = true;
      });

      // 10 points for each correct answer.
      if (!_pointsAdded) {
        DataService.addPoints(_correctAnswers * 10);
        _pointsAdded = true;
      }
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _correctAnswers = 0;
      _quizFinished = false;
      _pointsAdded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = DataService.quizQuestions.length;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Quiz Section'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _quizFinished
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Text(
                            'Quiz Completed!',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Correct Answers: $_correctAnswers / $totalQuestions',
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Points Added: ${_correctAnswers * 10}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _restartQuiz,
                    child: const Text('Restart Quiz'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/score'),
                    child: const Text('View Score'),
                  ),
                ],
              )
            : _buildQuestionCard(),
      ),
    );
  }

  Widget _buildQuestionCard() {
    final question = DataService.quizQuestions[_currentIndex];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question ${_currentIndex + 1}/${DataService.quizQuestions.length}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  question.topic,
                  style: const TextStyle(
                    color: Colors.teal,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(
          question.options.length,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ElevatedButton(
              onPressed: () => _selectAnswer(index),
              child: Text(question.options[index]),
            ),
          ),
        ),
      ],
    );
  }
}
