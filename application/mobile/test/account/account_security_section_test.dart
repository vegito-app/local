import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../lib/account/account_security_section.dart';
import '../../lib/auth/auth_provider.dart';

// Mock utilisateur
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-user-id';

  @override
  String? get displayName => 'TestUser';

  @override
  String? get email => 'test@example.com';

  @override
  bool get isAnonymous => false;
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  User? get user => MockUser();

  @override
  bool get isAuthenticated => true;

  @override
  bool get isAnonymous => false;

  @override
  Future<void> loadBalance() async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
      'AccountSecuritySection affiche les statuts et le bouton de rafraîchissement',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: AccountSecuritySection(),
          ),
        ),
      ),
    );

    expect(find.text('Statut de sécurité :'), findsNWidgets(2));
    expect(find.text('Sécurisé'), findsOneWidget);
    expect(find.text('Mon activité'), findsOneWidget);
    expect(find.text('Rafraîchir'), findsOneWidget);
  });
}
