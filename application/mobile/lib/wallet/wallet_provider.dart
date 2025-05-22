import 'package:car2go/wallet/wallet_backend.dart';
import 'package:car2go/wallet/wallet_service.dart';
import 'package:car2go/wallet/wallet_store.dart';
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  WalletState? _walletState;
  bool _isLoading = false;
  String? _error;

  WalletState? get wallet => _walletState;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> refresh(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _walletState = await loadWallet(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}

class WalletState {
  final String? recoveryKey;
  final String? recoveryKeyVersion;
  final bool isCompromised;

  const WalletState({
    required this.recoveryKey,
    required this.recoveryKeyVersion,
    required this.isCompromised,
  });
}

Future<WalletState> loadWallet(String userId) async {
  final privateKey = await getPrivateKeyWIF();
  if (privateKey.contains("compromis")) {
    return const WalletState(
      recoveryKey: "Appareil compromis, accès refusé.",
      recoveryKeyVersion: "Impossible",
      isCompromised: true,
    );
  }

  final recoveryKey = await WalletStorage.getLocallyStoredRecoveryKey();
  final recoveryKeyVersion = await getRecoveryKeyVersion(userId);

  return WalletState(
    recoveryKey: recoveryKey,
    recoveryKeyVersion: recoveryKeyVersion ?? "Version inconnue",
    isCompromised: false,
  );
}
