import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:campusmart/widgets/app_row.dart';

void main() {
  testWidgets('AppRow displays content and trailing widget',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppRow(
            trailing: Icon(Icons.chevron_right),
            child: Text('Title'),
          ),
        ),
      ),
    );

    expect(find.text('Title'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });
}
