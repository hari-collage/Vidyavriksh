import 'package:flutter/material.dart';

import '../models/question_model.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class GkScreen extends StatefulWidget {
  const GkScreen({super.key});

  @override
  State<GkScreen> createState() => _GkScreenState();
}

class _GkScreenState extends State<GkScreen> {
  late Question _gkQuestion;
  bool _answered = false;
  int? _selectedIndex;
  String _resultMessage = '';

  @override
  void initState() {
    super.initState();
    _gkQuestion = DataService.getRandomGkQuestion();
  }

  void _answerQuestion(int index) {
    if (_answered) return;

    final isCorrect = index == _gkQuestion.correctAnswerIndex;
    if (isCorrect) {
      DataService.addPoints(5);
    }

    setState(() {
      _answered = true;
      _selectedIndex = index;
      _resultMessage = isCorrect
          ? 'Correct! You earned 5 points.'
          : 'Wrong answer. Better luck next time.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Daily GK'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s GK Question',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _gkQuestion.questionText,
                      style: const TextStyle(fontSize: 17),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _gkQuestion.options.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ElevatedButton(
                  onPressed: _answered ? null : () => _answerQuestion(index),
                  child: Text(_gkQuestion.options[index]),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (_answered)
              Card(
                color: _selectedIndex == _gkQuestion.correctAnswerIndex
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _resultMessage,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
