import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:eventneo/core/widgets/neo_widgets.dart';

void main() {
  testWidgets('NeoButton renders its label', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NeoButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );

    expect(find.text('Continue'), findsOneWidget);
  });
}
