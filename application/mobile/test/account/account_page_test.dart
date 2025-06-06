import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../test_double.dart';
import '../../lib/auth/auth_provider.dart';
import '../../lib/account/account_page.dart';

void main() {
  testWidgets('AccountPage affiche tous les composants attendus',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: AccountPage(),
        ),
      ),
    );

    expect(find.text("Mon Compte"), findsOneWidget);
    expect(find.text("Solde :"), findsOneWidget);
    expect(find.text("Statut de connexion :"), findsOneWidget);
    expect(find.text("Adresse e-mail :"), findsOneWidget);
    expect(find.text("Profil public"), findsOneWidget);
    expect(find.text("Autoriser les évaluations publiques"), findsOneWidget);
    expect(find.text("Mon activité"), findsOneWidget);
  });
}
