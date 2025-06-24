import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:vegito/auth/auth_provider.dart';

class MockUser implements User {
  @override
  String get uid => '123456';

  @override
  String? get displayName => 'TestUser';

  @override
  String? get email => 'test@example.com';

  @override
  bool get isAnonymous => false;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  User? get user => MockUser();

  @override
  bool get isAuthenticated => true;

  @override
  bool get isAnonymous => false;

  @override
  String get balance => "123.45 €";

  @override
  bool get loadingBalance => false;

  @override
  Future<void> loadBalance() async {}

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
