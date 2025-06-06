import 'package:car2go/account/account_validate.dart';
import 'package:car2go/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import '../mocks.mocks.dart';

void main() {
  testWidgets('AccountValidate appelle upgradeWithEmail et affiche message',
      (WidgetTester tester) async {
    final mockAuthProvider = MockAuthProvider();

    when(mockAuthProvider.upgradeWithEmail(any, any))
        .thenAnswer((_) async => Future.value());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: mockAuthProvider,
        child: const MaterialApp(
          home: Scaffold(
            body: AccountValidate(),
          ),
        ),
      ),
    );

    // Remplissage des champs
    final emailField = find.byKey(const Key('emailField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final submitButton = find.byKey(const Key('submitButton'));

    expect(emailField, findsOneWidget);
    expect(passwordField, findsOneWidget);
    expect(submitButton, findsOneWidget);

    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password123');

    await tester.tap(submitButton);
    await tester.pump();

    verify(mockAuthProvider.upgradeWithEmail('test@example.com', 'password123'))
        .called(1);

    expect(find.textContaining('Compte sécurisé'), findsOneWidget);
  });
}
