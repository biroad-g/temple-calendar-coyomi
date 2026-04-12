import 'package:flutter_test/flutter_test.dart';
import 'package:temple_calendar/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TempleCalendarApp());
    expect(find.byType(TempleCalendarApp), findsOneWidget);
  });
}
