import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:payloadlab/app.dart';

void main() {
  testWidgets('PayloadLab starts', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PayloadLabApp()));
    await tester.pumpAndSettle();
    expect(find.text('PayloadLab'), findsWidgets);
    expect(find.text('Payload Studio'), findsOneWidget);
  });
}
