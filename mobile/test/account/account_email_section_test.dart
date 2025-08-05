import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vegito/account/account_email_section.dart';
import 'package:vegito/auth/auth_provider.dart';

import '../test_double.dart';

void main() {
  testWidgets('AccountEmailSection affiche l’e-mail de l’utilisateur',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: AccountEmailSection(),
          ),
        ),
      ),
    );

    expect(find.text('Adresse e-mail :'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
  });
}
