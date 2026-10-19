import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app test harness renders a basic widget', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Career App'),
        ),
      ),
    );

    expect(find.text('Career App'), findsOneWidget);
  });
}
