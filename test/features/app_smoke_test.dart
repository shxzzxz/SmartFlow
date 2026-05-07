import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartflow/app/app.dart';

void main() {
  testWidgets('renders the stage 0 app shell', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartFlowApp()));

    expect(find.text('SmartFlow'), findsOneWidget);
    expect(find.text('本地复式记账'), findsOneWidget);
    expect(find.text('Material 3'), findsOneWidget);
  });
}
