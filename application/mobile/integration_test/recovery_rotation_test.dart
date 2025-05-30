import 'dart:convert';
import 'dart:math';

import 'package:car2go/config.dart'; // adapte ce chemin
import 'package:car2go/firebase_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

String generateKey() {
  final random = Random.secure();
  final values = List<int>.generate(32, (_) => random.nextInt(256));
  return base64Encode(values);
}

Future<void> main() async {
  const backendUrl = Config.backendUrl;

  TestWidgetsFlutterBinding.ensureInitialized();

  final configService = FirebaseConfigService();
  final options =
      await configService.getConfig('$backendUrl/ui/config/firebase');
  await Firebase.initializeApp(options: options);

  FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  const testEmail = 'test@example.com';
  const testPassword = '123456';

  group('Recovery Key Integration Test', () {
    testWidgets('sign in + rotate recovery key', (tester) async {
      // Create user if not exists
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      } catch (_) {
        // user already exists
      }

      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: testEmail, password: testPassword);

      final userId = userCredential.user?.uid;
      final recoveryKey = generateKey();

      final response = await http.post(
        Uri.parse('$backendUrl/user/rotate-recoverykey'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "userId": userId,
          "recoveryKey": recoveryKey,
        }),
      );

      expect(response.statusCode, equals(200));
      expect(response.body.contains("rotated"), isTrue);
    });
  });
}
