import 'package:flutter/material.dart';

import '../widgets/app_back_button.dart';

class StudentResultsScreen extends StatelessWidget {
  const StudentResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> dummyResults = [
      {
        'studentName': 'Aarav',
        'quizScore': '18/20',
        'totalPoints': '145',
        'completedCourses': '4',
      },
      {
        'studentName': 'Diya',
        'quizScore': '16/20',
        'totalPoints': '132',
        'completedCourses': '3',
      },
      {
        'studentName': 'Kabir',
        'quizScore': '19/20',
        'totalPoints': '156',
        'completedCourses': '5',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Student Results'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dummyResults.length,
        itemBuilder: (context, index) {
          final result = dummyResults[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student Name: ${result['studentName']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text('Quiz Score: ${result['quizScore']}'),
                  Text('Total Points: ${result['totalPoints']}'),
                  Text('Completed Courses: ${result['completedCourses']}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
