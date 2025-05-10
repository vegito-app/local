import 'package:car2go/wallet/wallet_service.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class ShowRecoveryKeyButton extends StatefulWidget {
  const ShowRecoveryKeyButton({super.key});

  @override
  State<ShowRecoveryKeyButton> createState() => _ShowRecoveryKeyButtonState();
}

class _ShowRecoveryKeyButtonState extends State<ShowRecoveryKeyButton> {
  String? _recoveryKey;
  bool _revealed = false;

  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> _authenticateBiometric() async {
    // Désactiver la biométrie dans l'émulateur ou en mode debug
    const bool disableBiometric = kDebugMode ||
        !bool.fromEnvironment("USE_BIOMETRIC", defaultValue: true);

    if (disableBiometric) return true;

    final isAvailable = await auth.canCheckBiometrics;
    final isDeviceSupported = await auth.isDeviceSupported();

    if (!isAvailable || !isDeviceSupported) return false;

    try {
      return await auth.authenticate(
        localizedReason: 'Authentifiez-vous pour accéder à la clé privée',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      debugPrint("Erreur auth biométrique : $e");
      return false;
    }
  }

  Future<void> _loadRecoveryKey() async {
    final key = await getRecoveryKey();
    setState(() => _recoveryKey = key);
  }

  void _copyToClipboard(BuildContext context) {
    if (_recoveryKey != null) {
      FlutterClipboard.copy(_recoveryKey!).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Clé copiée ! Soyez prudent.")),
        );
      });
    }
  }

  String _obscureKey(String key) {
    if (key.length <= 8) return "********";
    return "${key.substring(0, 4)}...${key.substring(key.length - 4)}";
  }

  void _revealTemporarily() {
    setState(() => _revealed = true);
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() => _revealed = false);
      }
    });
  }

  Future<void> _confirmAndLoadKey(BuildContext context) async {
    // final confirmed = await showDialog<bool>(
    //       context: context,
    //       builder: (context) => AlertDialog(
    //         title: const Text("Confirmation"),
    //         content: const Text(
    //             "Souhaitez-vous vraiment afficher votre clé privée ? Toute personne qui la voit peut accéder à vos fonds."),
    //         actions: [
    //           TextButton(
    //             onPressed: () => Navigator.pop(context, false),
    //             child: const Text("Annuler"),
    //           ),
    //           TextButton(
    //             onPressed: () => Navigator.pop(context, true),
    //             child: const Text("Continuer"),
    //           ),
    //         ],
    //       ),
    //     ) ??
    //     false;

    // if (!confirmed) return;

    final isAuth = await _authenticateBiometric();
    if (!isAuth) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Authentification biométrique requise.")),
      );
      return;
    }

    await _loadRecoveryKey();

    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Clé privée sécurisée"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_recoveryKey == null) const CircularProgressIndicator(),
              if (_recoveryKey != null)
                Text(
                  _revealed ? _recoveryKey! : _obscureKey(_recoveryKey!),
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!_revealed)
                    TextButton(
                      onPressed: _revealTemporarily,
                      child: const Text("Révéler 10s"),
                    ),
                  TextButton(
                    onPressed: () {
                      _copyToClipboard(context);
                      Navigator.pop(context);
                    },
                    child: const Text("Copier"),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.lock),
      label: const Text("Afficher ma clé de récupération"),
      onPressed: () => _confirmAndLoadKey(context),
    );
  }
}
