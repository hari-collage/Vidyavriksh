import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/app_user_model.dart';
import '../models/course_post_model.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  AppUser? get _currentStudent {
    final user = DataService.currentUserNotifier.value;
    if (user == null) return null;
    if (user.role.toLowerCase() != 'student') return null;
    return user;
  }

  Future<void> _openLink(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the website link.')),
      );
    }
  }

  Future<void> _openVideoLink(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    final success = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open video link.')),
      );
    }
  }

  void _showPdfInfo(String fileName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          fileName.isEmpty
              ? 'PDF uploaded in app storage by teacher.'
              : 'PDF uploaded: $fileName',
        ),
      ),
    );
  }

  void _recordCourseAttempt(CoursePost post) {
    final student = _currentStudent;
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Student profile not found. Please login again.')),
      );
      return;
    }

    DataService.recordCourseAttempt(course: post, student: student);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course attempt recorded.')),
    );
  }

  void _showQuizDialog(BuildContext context, CoursePost post) {
    final student = _currentStudent;
    if (student == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Student profile not found. Please login again.')),
      );
      return;
    }

    final marksController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Course Quiz (${post.quizType})'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.quizContent),
                const SizedBox(height: 12),
                TextField(
                  controller: marksController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Marks Gained',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                final marks = int.tryParse(marksController.text.trim());
                if (marks == null || marks < 0) {
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid marks.')),
                  );
                  return;
                }

                DataService.recordQuizAttempt(
                  course: post,
                  student: student,
                  marks: marks,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(content: Text('Quiz attempt recorded.')),
                );
              },
              child: const Text('Submit Marks'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTeacherCourseCard(BuildContext context, CoursePost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              post.courseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'By: ${post.teacherName}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(post.courseDescription),
            if (post.textBlog.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Text(
                'Text-Blog',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(post.textBlog),
            ],
            if (post.pdfFileName.isNotEmpty || post.pdfBytes != null) ...[
              const SizedBox(height: 10),
              Text(
                'Uploaded PDF: ${post.pdfFileName.isEmpty ? 'PDF File' : post.pdfFileName}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => _showPdfInfo(post.pdfFileName),
                child: const Text('View PDF Info'),
              ),
            ],
            if (post.videoLink.isNotEmpty) ...[
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _openVideoLink(post.videoLink, context),
                child: const Text('Open Video Link'),
              ),
            ],
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _recordCourseAttempt(post),
              child: const Text('Mark Course Attempt'),
            ),
            const SizedBox(height: 8),
            Text(
              'Quiz Type: ${post.quizType}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            ElevatedButton(
              onPressed: () => _showQuizDialog(context, post),
              child: const Text('Attempt Course Quiz'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topics = DataService.learningTopics;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Learning'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...topics.map((topic) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['title']!,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(topic['description']!),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _openLink(topic['url']!, context),
                      child: const Text('Open Learning Link'),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Uploaded Study Materials',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<Map<String, dynamic>>>(
            valueListenable: DataService.studyMaterialsNotifier,
            builder: (context, materials, child) {
              if (materials.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'No study materials uploaded yet.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: materials.map((material) {
                  final resourceType =
                      (material['resourceType'] as String?) ?? '';
                  final link = (material['link'] as String?) ?? '';
                  final pdfName = (material['pdfName'] as String?) ?? '';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (material['title'] as String?) ?? '',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                              'Subject: ${(material['subject'] as String?) ?? ''}'),
                          Text('Type: $resourceType'),
                          const SizedBox(height: 6),
                          Text((material['description'] as String?) ?? ''),
                          const SizedBox(height: 10),
                          if (resourceType == 'PDF')
                            ElevatedButton(
                              onPressed: () => _showPdfInfo(pdfName),
                              child: const Text('View PDF Info'),
                            )
                          else
                            ElevatedButton(
                              onPressed: () => _openLink(link, context),
                              child: const Text('Open Material'),
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Teacher Posted Courses',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<List<CoursePost>>(
            valueListenable: DataService.postedCoursesNotifier,
            builder: (context, posts, child) {
              if (posts.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(14),
                    child: Text(
                      'No course posted yet by Teacher.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return Column(
                children: posts
                    .map((post) => _buildTeacherCourseCard(context, post))
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
