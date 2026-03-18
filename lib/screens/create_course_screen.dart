import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../models/course_post_model.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class CreateCourseScreen extends StatefulWidget {
  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _youtubeLinkController = TextEditingController();
  final TextEditingController _blogLinkController = TextEditingController();

  String _difficultyLevel = 'Beginner';
  String _pickedPdfName = '';
  Uint8List? _pickedPdfBytes;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _youtubeLinkController.dispose();
    _blogLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickPdfFromComputer() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      setState(() {
        _pickedPdfName = file.name;
        _pickedPdfBytes = file.bytes;
      });
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected PDF: ${file.name}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick PDF file.')),
      );
    }
  }

  void _submitCourse() {
    final AppUser? teacher = DataService.currentUserNotifier.value;
    if (teacher == null) return;

    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final subject = _subjectController.text.trim();
    final youtube = _youtubeLinkController.text.trim();
    final blog = _blogLinkController.text.trim();

    if (title.isEmpty || description.isEmpty || subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill course title, description and subject.'),
        ),
      );
      return;
    }

    DataService.addCoursePost(
      CoursePost(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        teacherEmail: teacher.email,
        teacherName: teacher.displayName,
        courseName: title,
        courseDescription:
            '$description\nSubject: $subject\nDifficulty: $_difficultyLevel',
        textBlog: blog,
        videoLink: youtube,
        quizType: 'Not Added',
        quizContent: 'Quiz will be added by teacher from Create Quiz screen.',
        pdfFileName: _pickedPdfName,
        pdfBytes: _pickedPdfBytes,
      ),
    );

    _titleController.clear();
    _descriptionController.clear();
    _subjectController.clear();
    _youtubeLinkController.clear();
    _blogLinkController.clear();

    setState(() {
      _pickedPdfName = '';
      _pickedPdfBytes = null;
      _difficultyLevel = 'Beginner';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Course created successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Create Course'),
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
                    'Create Learning Module',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Course Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject Category',
                      hintText: 'Type subject here',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _difficultyLevel,
                    decoration: const InputDecoration(
                      labelText: 'Difficulty Level',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Beginner',
                        child: Text('Beginner'),
                      ),
                      DropdownMenuItem(
                        value: 'Intermediate',
                        child: Text('Intermediate'),
                      ),
                      DropdownMenuItem(
                        value: 'Hard',
                        child: Text('Hard'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _difficultyLevel = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _youtubeLinkController,
                    decoration: const InputDecoration(
                      labelText: 'YouTube Video Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _blogLinkController,
                    decoration: const InputDecoration(
                      labelText: 'Blog or Article Link',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PDF Notes Upload',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _pickPdfFromComputer,
                    child: const Text('Choose PDF From Computer'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pickedPdfName.isEmpty ? 'No PDF selected' : _pickedPdfName,
                    style: const TextStyle(color: Colors.black87),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _submitCourse,
                    child: const Text('Create Course'),
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
