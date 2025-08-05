// ignore_for_file: directives_ordering

import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Firebase Anonymous Login works', (WidgetTester tester) async {
    await Firebase.initializeApp();

    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      UserCredential result = await FirebaseAuth.instance.signInAnonymously();
      user = result.user;
    }

    expect(user, isNotNull);
    expect(user!.isAnonymous, true);
  });
}
