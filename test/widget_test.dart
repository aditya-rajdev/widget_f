import 'package:flutter_test/flutter_test.dart';
import 'package:widget/main.dart';

void main() {
  testWidgets('App renders title and add link button', (WidgetTester tester) async {
    await tester.pumpWidget(const ZurlApp());

    expect(find.text('Zurl'), findsOneWidget);
    expect(find.text('+ Add Link'), findsOneWidget);
  });
}
