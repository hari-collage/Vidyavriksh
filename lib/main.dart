import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/select_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/teacher_dashboard_screen.dart';
import 'screens/learning_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/gk_screen.dart';
import 'screens/score_screen.dart';

void main() {
  runApp(const EduLiftIndiaApp());
}

class EduLiftIndiaApp extends StatelessWidget {
  const EduLiftIndiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VidyaVriksh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        if (settings.name == '/auth') {
          final role = settings.arguments as String? ?? 'Student';
          return MaterialPageRoute(
            builder: (_) => AuthScreen(role: role),
          );
        }
        return null;
      },
      routes: {
        '/': (_) => const WelcomeScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/select': (_) => const SelectScreen(),
        '/home': (_) => const HomeScreen(),
        '/teacher-dashboard': (_) => const TeacherDashboardScreen(),
        '/learning': (_) => const LearningScreen(),
        '/quiz': (_) => const QuizScreen(),
        '/gk': (_) => const GkScreen(),
        '/score': (_) => const ScoreScreen(),
      },
    );
  }
}
