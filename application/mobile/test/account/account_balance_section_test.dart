import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vegito/account/account_balance_section.dart';

import '../../lib/auth/auth_provider.dart';

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  String get balance => "123.45€";

  @override
  bool get loadingBalance => false;

  @override
  Future<void> loadBalance() async {}

  // implémentations stubs pour les autres méthodes non utilisées
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('AccountBalanceSection shows balance and refresh button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: FakeAuthProvider(),
        child: const MaterialApp(
          home: Scaffold(
            body: AccountBalanceSection(),
          ),
        ),
      ),
    );

    expect(find.text('Solde :'), findsOneWidget);
    expect(find.text('123.45€'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
