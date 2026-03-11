import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class StudentDoubtsScreen extends StatefulWidget {
  const StudentDoubtsScreen({super.key});

  @override
  State<StudentDoubtsScreen> createState() => _StudentDoubtsScreenState();
}

class _StudentDoubtsScreenState extends State<StudentDoubtsScreen> {
  final Map<int, TextEditingController> _replyControllers = {};

  @override
  void dispose() {
    for (final controller in _replyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(int index) {
    return _replyControllers.putIfAbsent(index, TextEditingController.new);
  }

  void _replyToDoubt(int index) {
    final reply = _getController(index).text.trim();
    if (reply.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reply first.')),
      );
      return;
    }

    DataService.replyToDoubt(index: index, reply: reply);
    _getController(index).clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reply submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Student Doubts'),
      ),
      body: ValueListenableBuilder<List<Map<String, String>>>(
        valueListenable: DataService.studentDoubtsNotifier,
        builder: (context, doubts, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doubts.length,
            itemBuilder: (context, index) {
              final doubt = doubts[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${doubt['studentName'] ?? ''}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text('Question: ${doubt['question'] ?? ''}'),
                      if ((doubt['reply'] ?? '').isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text('Teacher Reply: ${doubt['reply']}'),
                      ],
                      const SizedBox(height: 10),
                      TextField(
                        controller: _getController(index),
                        decoration: const InputDecoration(
                          labelText: 'Reply',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => _replyToDoubt(index),
                        child: const Text('Send Reply'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
