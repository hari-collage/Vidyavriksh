import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class PostDailyGkScreen extends StatefulWidget {
  const PostDailyGkScreen({super.key});

  @override
  State<PostDailyGkScreen> createState() => _PostDailyGkScreenState();
}

class _PostDailyGkScreenState extends State<PostDailyGkScreen> {
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _optionAController = TextEditingController();
  final TextEditingController _optionBController = TextEditingController();
  final TextEditingController _optionCController = TextEditingController();
  final TextEditingController _optionDController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();

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

  void _postGk() {
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all GK fields.')),
      );
      return;
    }

    DataService.addDailyGkPost({
      'question': question,
      'optionA': optionA,
      'optionB': optionB,
      'optionC': optionC,
      'optionD': optionD,
      'correctAnswer': _correctAnswer,
      'points': points,
    });

    _questionController.clear();
    _optionAController.clear();
    _optionBController.clear();
    _optionCController.clear();
    _optionDController.clear();
    _pointsController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Daily GK posted successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Post Daily GK'),
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
                    'Post Daily GK',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    onPressed: _postGk,
                    child: const Text('Post GK Question'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
