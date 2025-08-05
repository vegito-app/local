import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../security_warning_screen.dart';
import 'auth_provider.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!authProvider.isAuthenticated) {
          return const SecurityWarningScreen();
        }

        return child;
      },
    );
  }
}
