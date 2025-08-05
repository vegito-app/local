import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:vegito/account/account_reputation_toggle_section.dart';
// Remplacez les imports suivants par les bons chemins si nécessaire
import 'package:vegito/auth/auth_provider.dart';

class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  User? get user => MockUser();

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'AccountReputationToggleSection affiche un switch avec valeur correcte',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream:
                  Stream.value(FakeDocumentSnapshot({"reputationOptIn": true})),
              builder: (context, snapshot) {
                return const AccountReputationToggleSection();
              },
            ),
          ),
        ),
      ),
    );

    // Vérifie que le SwitchListTile est présent
    expect(find.byType(SwitchListTile), findsOneWidget);
    // Vérifie que le texte est correct
    expect(find.text('Autoriser les évaluations publiques'), findsOneWidget);
    // Vérifie la valeur du switch (doit être true)
    final switchTile =
        tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(switchTile.value, isTrue);
  });

  testWidgets(
      'AccountReputationToggleSection affiche le message d\'explication',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: MaterialApp(
          home: Scaffold(
            body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: Stream.value(
                  FakeDocumentSnapshot({"reputationOptIn": false})),
              builder: (context, snapshot) {
                return const AccountReputationToggleSection();
              },
            ),
          ),
        ),
      ),
    );

    // Vérifie que le texte d’explication est visible
    expect(
      find.textContaining(
          'une note moyenne basée sur les évaluations reçues vous sera attribuée'),
      findsOneWidget,
    );
  });
}

// Fake document snapshot pour simuler Firestore
class FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  FakeDocumentSnapshot(this._data);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  bool get exists => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
