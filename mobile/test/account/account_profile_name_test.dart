import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vegito/account/account_profile_name.dart';
import 'package:vegito/auth/auth_provider.dart' as auth_provider;

import '../test_double.dart';

void main() {
  testWidgets('AccountProfileName displays user displayName',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<auth_provider.AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: AccountProfileName(),
          ),
        ),
      ),
    );

    final textFieldFinder = find.byType(TextFormField);
    expect(textFieldFinder, findsOneWidget);

    final textFormField = tester.widget<TextFormField>(textFieldFinder);
    expect(textFormField.initialValue, "TestUser");
  });
}
