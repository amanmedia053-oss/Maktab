import 'package:flutter_test/flutter_test.dart';
import 'package:maktab/main.dart';

void main() {
  testWidgets('Maktab dashboard renders in Pashto', (tester) async {
    await tester.pumpWidget(const MaktabApp(dark: false));
    await tester.pump();
    expect(find.text('مکتب'), findsOneWidget);
    expect(find.text('ښه راغلاست!'), findsOneWidget);
  });
}
