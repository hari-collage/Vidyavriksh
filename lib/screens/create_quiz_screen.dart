import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class CreateQuizScreen extends StatefulWidget {
  const CreateQuizScreen({super.key});

  @override
  State<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends State<CreateQuizScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

  final List<Map<String, String>> _draftQuestions = [];
  String _correctAnswer = 'A';

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Map<String, String>? _buildQuestionFromForm() {
    final question = _questionController.text.trim();
    final optionA = _optionAController.text.trim();
    final optionB = _optionBController.text.trim();
    final optionC = _optionCController.text.trim();
    final optionD = _optionDController.text.trim();
    final points = _pointsController.text.trim();

    if (question.isEmpty ||
        optionA.isEmpty ||
        optionB.isEmpty ||
        optionC.isEmpty ||
        optionD.isEmpty ||
        points.isEmpty) {
      return null;
    }

    return {
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': _correctAnswer,
      'points': points,
    };
  }

  bool _isCurrentFormEmpty() {
    return _questionController.text.trim().isEmpty &&
        _optionAController.text.trim().isEmpty &&
        _optionBController.text.trim().isEmpty &&
        _optionCController.text.trim().isEmpty &&
        _optionDController.text.trim().isEmpty &&
        _pointsController.text.trim().isEmpty;
  }

  void _clearForm() {
    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _pointsController.clear();
    setState(() {
      _correctAnswer = 'A';
    });
  }

  void _addMoreQuestion() {
    final questionMap = _buildQuestionFromForm();
    if (questionMap == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all quiz fields first.')),
      );
      return;
    }

    setState(() {
      _draftQuestions.add(questionMap);
    });
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Added. Draft questions: ${_draftQuestions.length}')),
    );
  }

  void _saveAllQuestions() {
    final questionsToSave = List<Map<String, String>>.from(_draftQuestions);

    if (!_isCurrentFormEmpty()) {
      final currentQuestion = _buildQuestionFromForm();
      if (currentQuestion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Current form is incomplete. Complete it or clear it before saving.',
            ),
          ),
        );
        return;
      }
      questionsToSave.add(currentQuestion);
    }

    if (questionsToSave.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No questions to save yet.')),
      );
      return;
    }

    for (final question in questionsToSave) {
      DataService.addTeacherQuizQuestion(question);
    }

    setState(() {
      _draftQuestions.clear();
    });
    _clearForm();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('${questionsToSave.length} quiz question(s) saved.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Create Quiz'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create Quiz Question',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Draft questions in this batch: ${_draftQuestions.length}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _questionController,
                    decoration: const InputDecoration(
                      labelText: 'Question',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _optionAController,
                    decoration: const InputDecoration(
                      labelText: 'Option A',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _optionBController,
                    decoration: const InputDecoration(
                      labelText: 'Option B',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _optionCController,
                    decoration: const InputDecoration(
                      labelText: 'Option C',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _optionDController,
                    decoration: const InputDecoration(
                      labelText: 'Option D',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _correctAnswer,
                    decoration: const InputDecoration(
                      labelText: 'Correct Answer',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'A', child: Text('A')),
                      DropdownMenuItem(value: 'B', child: Text('B')),
                      DropdownMenuItem(value: 'C', child: Text('C')),
                      DropdownMenuItem(value: 'D', child: Text('D')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _correctAnswer = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Points',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _addMoreQuestion,
                    child: const Text('Add More Question'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _saveAllQuestions,
                    child: const Text('Save Quiz Questions'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Stored Quiz Questions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<List<Map<String, String>>>(
            valueListenable: DataService.teacherQuizNotifier,
            builder: (context, questions, child) {
              if (questions.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No quiz questions added yet.'),
                  ),
                );
              }

              return Column(
                children: questions.map((q) {
                  return Card(
                    child: ListTile(
                      title: Text(q['question'] ?? ''),
                      subtitle: Text(
                        'Correct: ${q['correctAnswer']} | Points: ${q['points']}',
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
