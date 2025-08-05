import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vegito/account/account_auth_status_section.dart';
import 'package:vegito/auth/auth_provider.dart';

import '../test_double.dart';

void main() {
  testWidgets('AccountAuthStatusSection affiche "Connecté"', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: AccountAuthStatusSection(),
          ),
        ),
      ),
    );

    expect(find.text("Statut de connexion :"), findsOneWidget);
    expect(find.text("Connecté"), findsOneWidget);
  });
}
