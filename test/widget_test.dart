import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:edulift_india/main.dart';

void main() {
  testWidgets('Welcome screen appears with app name and loading circle', (WidgetTester tester) async {
    await tester.pumpWidget(const EduLiftIndiaApp());

    // Welcome page content.
    expect(find.text('VidyaVriksh'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
