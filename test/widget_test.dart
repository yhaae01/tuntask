import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tuntask/main.dart';

void main() {
  testWidgets('TunTask Board smoke test', (WidgetTester tester) async {
    // Set a wide screen size typical for desktop / web kanban board
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const TunTaskApp());
    await tester.pumpAndSettle();

    // Verify app title is rendered
    expect(find.text('TunTask Kanban'), findsOneWidget);

    // Verify default columns are present
    expect(find.text('TO DO'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    expect(find.text('IN REVIEW'), findsOneWidget);
    expect(find.text('DONE'), findsOneWidget);
  });
}
