import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../widgets/app_back_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final user = DataService.currentUserNotifier.value;
    final studentName = user?.displayName ?? 'Student';
    final studentProfileImageBytes = user?.profileImageBytes;
    final actions = <_StudentDashboardItem>[
      const _StudentDashboardItem(title: 'Learning', routeName: '/learning'),
      const _StudentDashboardItem(title: 'Quiz Section', routeName: '/quiz'),
      const _StudentDashboardItem(title: 'Daily GK', routeName: '/gk'),
      const _StudentDashboardItem(title: 'View Score', routeName: '/score'),
    ];

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Student Dashboard'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.teal,
                        backgroundImage: studentProfileImageBytes != null
                            ? MemoryImage(studentProfileImageBytes)
                            : const AssetImage('assets/student.png')
                                as ImageProvider,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        studentName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Discover knowledge, test your understanding, and keep learning.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: actions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.15,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final action = actions[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            action.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, action.routeName),
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
        ),
      ),
    );
  }
}

class _StudentDashboardItem {
  final String title;
  final String routeName;

  const _StudentDashboardItem({
    required this.title,
    required this.routeName,
  });
}
