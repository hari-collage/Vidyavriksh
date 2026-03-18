import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/app_user_model.dart';
import '../models/course_attempt_model.dart';
import '../models/course_post_model.dart';
import '../models/question_model.dart';
import '../models/teacher_result_model.dart';

class DataService {
  // Global score for the whole app.
  static final ValueNotifier<int> totalScoreNotifier = ValueNotifier<int>(0);

  static void addPoints(int points) {
    totalScoreNotifier.value += points;
  }

  // Simple in-app database for user profiles.
  static final Map<String, AppUser> _usersDb = {};
  static final ValueNotifier<AppUser?> currentUserNotifier =
      ValueNotifier<AppUser?>(null);

  static String _userKey(String role, String email) {
    return '${role.toLowerCase()}::${email.toLowerCase()}';
  }

  static void signupUser(AppUser user) {
    _usersDb[_userKey(user.role, user.email)] = user;
    currentUserNotifier.value = user;
  }

  static AppUser? loginUser({
    required String role,
    required String email,
    required String password,
  }) {
    final user = _usersDb[_userKey(role, email)];
    if (user == null) return null;
    if (user.password != password) return null;

    currentUserNotifier.value = user;
    return user;
  }

  static void updateCurrentUserProfile({
    String? displayName,
    String? phoneNumber,
    String? courseName,
    String? subjectExpertise,
    String? bio,
    Uint8List? profileImageBytes,
  }) {
    final current = currentUserNotifier.value;
    if (current == null) return;

    final updated = current.copyWith(
      displayName: displayName,
      phoneNumber: phoneNumber,
      courseName: courseName,
      subjectExpertise: subjectExpertise,
      bio: bio,
      profileImageBytes: profileImageBytes,
    );

    _usersDb[_userKey(updated.role, updated.email)] = updated;
    currentUserNotifier.value = updated;
  }

  // Teacher posted courses that students can view in learning section.
  static final ValueNotifier<List<CoursePost>> postedCoursesNotifier =
      ValueNotifier<List<CoursePost>>(<CoursePost>[]);

  static void addCoursePost(CoursePost post) {
    final current = List<CoursePost>.from(postedCoursesNotifier.value);
    current.insert(0, post);
    postedCoursesNotifier.value = current;
  }

  // Uploaded study material from teachers.
  static final ValueNotifier<List<Map<String, dynamic>>>
      studyMaterialsNotifier =
      ValueNotifier<List<Map<String, dynamic>>>(<Map<String, dynamic>>[]);

  static void addStudyMaterial(Map<String, dynamic> material) {
    final current =
        List<Map<String, dynamic>>.from(studyMaterialsNotifier.value);
    current.insert(0, material);
    studyMaterialsNotifier.value = current;
  }

  // Teacher-created quizzes.
  static final ValueNotifier<List<Map<String, String>>> teacherQuizNotifier =
      ValueNotifier<List<Map<String, String>>>(<Map<String, String>>[]);

  static void addTeacherQuizQuestion(Map<String, String> question) {
    final current = List<Map<String, String>>.from(teacherQuizNotifier.value);
    current.insert(0, question);
    teacherQuizNotifier.value = current;
  }

  // Teacher daily GK posts.
  static final ValueNotifier<List<Map<String, String>>> dailyGkPostsNotifier =
      ValueNotifier<List<Map<String, String>>>(<Map<String, String>>[]);

  static void addDailyGkPost(Map<String, String> gkPost) {
    final current = List<Map<String, String>>.from(dailyGkPostsNotifier.value);
    current.insert(0, gkPost);
    dailyGkPostsNotifier.value = current;
  }

  // Teacher announcements.
  static final ValueNotifier<List<Map<String, String>>> announcementsNotifier =
      ValueNotifier<List<Map<String, String>>>(<Map<String, String>>[]);

  static void addAnnouncement(Map<String, String> announcement) {
    final current = List<Map<String, String>>.from(announcementsNotifier.value);
    current.insert(0, announcement);
    announcementsNotifier.value = current;
  }

  // Student doubts and teacher replies.
  static final ValueNotifier<List<Map<String, String>>> studentDoubtsNotifier =
      ValueNotifier<List<Map<String, String>>>([
    {
      'studentName': 'Aarav',
      'question': 'I did not understand fractions.',
      'reply': '',
    },
    {
      'studentName': 'Diya',
      'question': 'Can you explain photosynthesis once again?',
      'reply': '',
    },
  ]);

  static void replyToDoubt({required int index, required String reply}) {
    final current = List<Map<String, String>>.from(studentDoubtsNotifier.value);
    final existing = Map<String, String>.from(current[index]);
    existing['reply'] = reply;
    current[index] = existing;
    studentDoubtsNotifier.value = current;
  }

  // Student attempt database: key = courseId::studentEmail
  static final Map<String, CourseAttempt> _attemptsDb = {};

  static String _attemptKey(String courseId, String studentEmail) {
    return '$courseId::${studentEmail.toLowerCase()}';
  }

  static void recordCourseAttempt({
    required CoursePost course,
    required AppUser student,
  }) {
    final key = _attemptKey(course.id, student.email);
    final existing = _attemptsDb[key];

    if (existing == null) {
      _attemptsDb[key] = CourseAttempt(
        courseId: course.id,
        studentEmail: student.email,
        studentName: student.displayName,
        courseAttempted: true,
        quizAttempted: false,
        marks: 0,
      );
      return;
    }

    _attemptsDb[key] = existing.copyWith(courseAttempted: true);
  }

  static void recordQuizAttempt({
    required CoursePost course,
    required AppUser student,
    required int marks,
  }) {
    final key = _attemptKey(course.id, student.email);
    final existing = _attemptsDb[key];

    if (existing == null) {
      _attemptsDb[key] = CourseAttempt(
        courseId: course.id,
        studentEmail: student.email,
        studentName: student.displayName,
        courseAttempted: true,
        quizAttempted: true,
        marks: marks,
      );
      return;
    }

    _attemptsDb[key] = existing.copyWith(
      courseAttempted: true,
      quizAttempted: true,
      marks: marks,
    );
  }

  static TeacherResultSummary getTeacherResultSummary(String teacherEmail) {
    final teacherCourseIds = postedCoursesNotifier.value
        .where((course) =>
            course.teacherEmail.toLowerCase() == teacherEmail.toLowerCase())
        .map((course) => course.id)
        .toSet();

    final relevantAttempts = _attemptsDb.values
        .where((attempt) => teacherCourseIds.contains(attempt.courseId))
        .toList();

    final courseStudents = relevantAttempts
        .where((attempt) => attempt.courseAttempted)
        .map((attempt) => attempt.studentEmail.toLowerCase())
        .toSet();

    final quizAttempts =
        relevantAttempts.where((attempt) => attempt.quizAttempted).toList();

    final quizStudents = quizAttempts
        .map((attempt) => attempt.studentEmail.toLowerCase())
        .toSet();

    int totalMarks = 0;
    final marksByStudent = <String, StudentMark>{};

    for (final attempt in quizAttempts) {
      totalMarks += attempt.marks;
      final existing = marksByStudent[attempt.studentEmail.toLowerCase()];

      if (existing == null) {
        marksByStudent[attempt.studentEmail.toLowerCase()] = StudentMark(
          studentName: attempt.studentName,
          marks: attempt.marks,
        );
      } else {
        marksByStudent[attempt.studentEmail.toLowerCase()] = StudentMark(
          studentName: existing.studentName,
          marks: existing.marks + attempt.marks,
        );
      }
    }

    final studentMarks = marksByStudent.values.toList()
      ..sort((a, b) => b.marks.compareTo(a.marks));

    return TeacherResultSummary(
      studentsAttemptedCourse: courseStudents.length,
      studentsAttemptedQuiz: quizStudents.length,
      totalMarks: totalMarks,
      studentMarks: studentMarks,
    );
  }

  static final List<Map<String, String>> learningTopics = [
    {
      'title': 'Basic Mathematics',
      'description':
          'Learn numbers, addition, subtraction, multiplication and division.',
      'url': 'https://www.khanacademy.org/math',
    },
    {
      'title': 'Science Fundamentals',
      'description':
          'Understand basic concepts in physics, chemistry and biology.',
      'url': 'https://www.britannica.com/science/science',
    },
    {
      'title': 'Indian History',
      'description':
          'Explore key events, leaders and important timelines of India.',
      'url': 'https://ncert.nic.in/textbook.php',
    },
    {
      'title': 'Computer Basics',
      'description':
          'Start with hardware, software, internet and digital skills.',
      'url': 'https://www.gcfglobal.org/en/computerbasics/',
    },
  ];

  static final List<Question> quizQuestions = [
    Question(
      questionText: 'What is 7 + 5?',
      options: ['10', '12', '14', '15'],
      correctAnswerIndex: 1,
      topic: 'Basic Mathematics',
    ),
    Question(
      questionText: 'Which gas do humans need to breathe?',
      options: ['Carbon Dioxide', 'Hydrogen', 'Oxygen', 'Nitrogen'],
      correctAnswerIndex: 2,
      topic: 'Science Fundamentals',
    ),
    Question(
      questionText: 'Who is known as the Father of the Nation in India?',
      options: [
        'Bhagat Singh',
        'Mahatma Gandhi',
        'Subhas Chandra Bose',
        'Nehru'
      ],
      correctAnswerIndex: 1,
      topic: 'Indian History',
    ),
    Question(
      questionText: 'Which of the following is an input device?',
      options: ['Monitor', 'Printer', 'Keyboard', 'Speaker'],
      correctAnswerIndex: 2,
      topic: 'Computer Basics',
    ),
  ];

  static final List<Question> gkQuestions = [
    Question(
      questionText: 'What is the capital of India?',
      options: ['Mumbai', 'New Delhi', 'Kolkata', 'Chennai'],
      correctAnswerIndex: 1,
      topic: 'General Knowledge',
    ),
    Question(
      questionText: 'How many colors are there in the Indian national flag?',
      options: ['2', '3', '4', '5'],
      correctAnswerIndex: 1,
      topic: 'General Knowledge',
    ),
    Question(
      questionText: 'Which planet is known as the Red Planet?',
      options: ['Venus', 'Earth', 'Mars', 'Jupiter'],
      correctAnswerIndex: 2,
      topic: 'General Knowledge',
    ),
  ];

  static Question getRandomGkQuestion() {
    final random = Random();
    return gkQuestions[random.nextInt(gkQuestions.length)];
  }
}
