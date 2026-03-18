import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../screens/announcements_screen.dart';
import '../screens/create_course_screen.dart';
import '../screens/create_quiz_screen.dart';
import '../screens/post_daily_gk_screen.dart';
import '../screens/student_doubts_screen.dart';
import '../screens/student_results_screen.dart';
import '../screens/teacher_profile_screen.dart';
import '../screens/upload_study_material_screen.dart';
import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  AppUser? get _teacher {
    final user = DataService.currentUserNotifier.value;
    if (user == null) return null;
    if (user.role.toLowerCase() != 'teacher') return null;
    return user;
  }

  @override
  Widget build(BuildContext context) {
    final teacher = _teacher;
    final teacherName = teacher?.displayName ?? 'Teacher';

    final items = <_DashboardItem>[
      _DashboardItem('Create Course', const CreateCourseScreen()),
      _DashboardItem(
          'Upload Study Material', const UploadStudyMaterialScreen()),
      _DashboardItem('Create Quiz', const CreateQuizScreen()),
      _DashboardItem('Post Daily GK', const PostDailyGkScreen()),
      _DashboardItem('View Student Results', const StudentResultsScreen()),
      _DashboardItem('Announcements', const AnnouncementsScreen()),
      _DashboardItem('Student Doubts', const StudentDoubtsScreen()),
      _DashboardItem('Edit Profile', const TeacherProfileScreen()),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Teacher Dashboard'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg_22.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: const Color(0xFFE8F0FF));
              },
            ),
          ),
          // Light overlay for readability while keeping background visible.
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.08)),
          ),
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Colors.white.withValues(alpha: 0.93),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Welcome, $teacherName',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.teal,
                        backgroundImage: teacher?.profileImageBytes != null
                            ? MemoryImage(teacher!.profileImageBytes!)
                            : null,
                        child: teacher?.profileImageBytes == null
                            ? const Icon(
                                Icons.person,
                                size: 44,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.08,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    color: Colors.white.withValues(alpha: 0.93),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => item.screen),
                              );
                            },
                            child: const Text('Open'),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashboardItem {
  final String title;
  final Widget screen;

  _DashboardItem(this.title, this.screen);
}
