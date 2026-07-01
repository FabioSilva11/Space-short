import 'package:flutter_test/flutter_test.dart';
import 'package:space_short/src/app/space_short_app.dart';

void main() {
  testWidgets('Space Short menu loads', (tester) async {
    await tester.pumpWidget(const SpaceShortApp());
    await tester.pump();

    expect(find.text('SPACE SHORT'), findsOneWidget);
  });
}
