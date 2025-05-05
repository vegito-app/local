import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WalletRecoveryKeySection extends StatelessWidget {
  final String? recoveryKey;
  final String? recoveryKeyVersion;
  final bool showRecoveryKey;
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;

  const WalletRecoveryKeySection({
    Key? key,
    required this.recoveryKey,
    required this.recoveryKeyVersion,
    required this.showRecoveryKey,
    required this.fadeAnimation,
    required this.scaleAnimation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (recoveryKey == null || recoveryKey!.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          "Aucune clé de récupération trouvée. Vous pouvez en générer une nouvelle.",
          style: TextStyle(fontSize: 16, color: Colors.orange),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ScaleTransition(
      scale: scaleAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(
              showRecoveryKey ? (recoveryKey ?? "") : "",
              style: const TextStyle(fontSize: 16, color: Colors.blue),
              textAlign: TextAlign.center,
            ),
            if (showRecoveryKey) ...[
              const SizedBox(height: 8),
              Text(
                "Version: ${recoveryKeyVersion ?? "?"}",
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: recoveryKey ?? ""));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'RecoveryKey copiée dans le presse-papier. Veuillez la protéger.',
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                },
                child: const Text("Copier la RecoveryKey"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
