import 'package:flutter_test/flutter_test.dart';

import 'package:cnnvisualizer/main.dart';

void main() {
  testWidgets('AI Vision Lab opens and navigates to the visualizer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AIVisionLabApp());

    expect(
      find.text('Learn Computer Vision through Interactive Visualization'),
      findsOneWidget,
    );
    expect(find.text('CNN Visualizer'), findsWidgets);

    await tester.tap(find.text('Visualizer'));
    await tester.pumpAndSettle();

    expect(find.text('ARCHITECTURE PIPELINE'), findsOneWidget);
  });
}
