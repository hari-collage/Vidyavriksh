import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/app_user_model.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _controllersLoaded = false;

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  AppUser? get _teacher {
    final user = DataService.currentUserNotifier.value;
    if (user == null) return null;
    if (user.role.toLowerCase() != 'teacher') return null;
    return user;
  }

  Future<void> _pickProfilePicture() async {
    final picker = ImagePicker();
    final file =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file == null) return;

    final bytes = await file.readAsBytes();
    DataService.updateCurrentUserProfile(profileImageBytes: bytes);
    setState(() {});
  }

  void _saveProfile() {
    DataService.updateCurrentUserProfile(
      displayName: _nameController.text.trim(),
      subjectExpertise: _subjectController.text.trim(),
      bio: _bioController.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated.')),
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final teacher = _teacher;
    final summary = teacher == null
        ? null
        : DataService.getTeacherResultSummary(teacher.email);

    if (teacher != null && !_controllersLoaded) {
      _nameController.text = teacher.displayName;
      _subjectController.text = teacher.subjectExpertise;
      _bioController.text = teacher.bio;
      _controllersLoaded = true;
    }

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Teacher Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: Colors.teal,
                    backgroundImage: teacher?.profileImageBytes != null
                        ? MemoryImage(teacher!.profileImageBytes!)
                        : null,
                    child: teacher?.profileImageBytes == null
                        ? const Icon(Icons.person,
                            color: Colors.white, size: 46)
                        : null,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _pickProfilePicture,
                    child: const Text('Change Profile Picture'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Teacher Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject Expertise',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Save Profile'),
                  ),
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total courses created: ${DataService.postedCoursesNotifier.value.where((c) => c.teacherEmail == teacher?.email).length}',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Total students: ${summary?.studentsAttemptedCourse ?? 0}',
                    ),
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
