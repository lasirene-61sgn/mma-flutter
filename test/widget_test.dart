import 'package:flutter_test/flutter_test.dart';
import 'package:mmp_official/main.dart';

void main() {
  testWidgets('IYA app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const IYAApp());
  });
}
