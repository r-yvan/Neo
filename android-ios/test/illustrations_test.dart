import 'package:eventneo/core/theme/app_theme.dart';
import 'package:eventneo/core/widgets/illustrations/neo_illustration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final bool dark in <bool>[false, true]) {
    for (final IllustrationKind kind in IllustrationKind.values) {
      testWidgets('${kind.name} paints through a full loop (dark=$dark)',
          (WidgetTester tester) async {
        await tester.pumpWidget(MaterialApp(
          theme: dark ? AppTheme.dark() : AppTheme.light(),
          home: Scaffold(body: NeoIllustration(kind: kind, height: 240)),
        ));
        // Step through the whole animation loop to hit every phase.
        for (int i = 0; i < 12; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
        expect(tester.takeException(), isNull);
        expect(find.byType(NeoIllustration), findsOneWidget);
      });
    }
  }

  testWidgets('honours reduce-motion with a still frame', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: const Scaffold(body: NeoIllustration(kind: IllustrationKind.rent)),
      ),
    ));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
