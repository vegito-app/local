import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:vegito/account/account_activity_button.dart';

void main() {
  testWidgets('AccountActivityButton affiche un bouton avec texte et icône',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AccountActivityButton(),
        ),
      ),
    );

    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text("Mon activité"), findsOneWidget);
    expect(find.byIcon(Icons.timeline), findsOneWidget);
  });
}
