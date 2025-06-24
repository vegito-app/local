import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vegito/auth/auth_provider.dart';

import '../mocks.mocks.dart';

void main() {
  late MockAuthService mockAuthService;
  late AuthProvider authProvider;
  late MockUser mockUser;

  setUp(() {
    mockAuthService = MockAuthService();
    authProvider = AuthProvider(service: mockAuthService);
    mockUser = MockUser();
  });

  test('upgradeWithEmail appelle AuthService et notifie', () async {
    when(mockAuthService.upgradeWithEmail(any, any))
        .thenAnswer((_) async => Future.value());

    when(mockUser.isAnonymous).thenReturn(true);
    when(authProvider.user).thenReturn(mockUser);

    await authProvider.upgradeWithEmail('test@example.com', 'password123');

    verify(mockAuthService.upgradeWithEmail('test@example.com', 'password123'))
        .called(1);
  });

  test('upgradeWithEmail ne fait rien si user null ou non anonyme', () async {
    when(authProvider.user).thenReturn(null);
    await authProvider.upgradeWithEmail('test@example.com', 'password123');
    verifyNever(mockAuthService.upgradeWithEmail(any, any));

    when(mockUser.isAnonymous).thenReturn(false);
    when(authProvider.user).thenReturn(mockUser);
    await authProvider.upgradeWithEmail('test2@example.com', 'pwd');
    verifyNever(mockAuthService.upgradeWithEmail(any, any));
  });
}
