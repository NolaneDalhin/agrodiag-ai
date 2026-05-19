import 'package:flutter_test/flutter_test.dart';
import 'package:agrodiag_ai/main.dart';

void main() {
  testWidgets('AgroDiag AI smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AgroDiagApp());
  });
}
