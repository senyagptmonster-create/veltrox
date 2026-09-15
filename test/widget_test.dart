import 'package:flutter_test/flutter_test.dart';
import 'package:veltrox/veltrox_app.dart';

void main() {
  testWidgets('VeltroxApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VeltroxApp());
    expect(find.text('Veltrox Sports Chrono'), findsOneWidget);
  });
}
