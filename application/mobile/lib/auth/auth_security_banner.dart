import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth_provider.dart';

enum AuthContext {
  general,
  account,
  wallet,
}

class AuthSecurityBanner extends StatefulWidget {
  final AuthContext contextType;
  final VoidCallback? onValidateAccount;

  const AuthSecurityBanner({
    super.key,
    this.contextType = AuthContext.general,
    this.onValidateAccount,
  });

  @override
  State<AuthSecurityBanner> createState() => _AuthSecurityBannerState();
}

class _AuthSecurityBannerState extends State<AuthSecurityBanner> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (_dismissed || !authProvider.isAnonymous) return const SizedBox.shrink();

    String getMessage() {
      switch (widget.contextType) {
        case AuthContext.wallet:
          return "🔐 Clé de récupération indisponible tant que votre compte est temporaire.";
        case AuthContext.account:
          return "⚠️ Compte temporaire : sécurisez-le pour accéder à vos données durablement.";
        case AuthContext.general:
        default:
          return "Vous êtes connecté anonymement. Pensez à valider votre identité.";
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
      child: Card(
        color: Colors.red.shade50,
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      getMessage(),
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => setState(() => _dismissed = true),
                  ),
                ],
              ),
            ),
            if (widget.onValidateAccount != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  onPressed: widget.onValidateAccount,
                  child: const Text("Valider mon compte"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
