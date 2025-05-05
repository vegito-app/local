import 'package:car2go/wallet/crypto/math.dart';
import 'package:car2go/wallet/crypto/stacks.dart';
import 'package:car2go/wallet/crypto/wif.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/ecc/api.dart';

import 'wallet_backend.dart';
import 'wallet_backend.dart';
import 'wallet_store.dart';

class WalletService {
  static WalletService? _instance;
  static bool _initialized = false;

  late final Uint8List _pubKey;
  late final String _addressTestnet;
  late final String _addressMainnet;

  WalletService._();

  static void init() {
    if (_initialized) return;
    _instance = WalletService._();
    _instance!._initialize();
    _initialized = true;
  }

  static WalletService get instance {
    if (!_initialized || _instance == null) {
      throw Exception('WalletService non initialisé. Appeler init() d’abord.');
    }
    return _instance!;
  }

  void _initialize() async {
    try {
      final existingKey = await WalletStorage.getPrivateKey();
      String privateKeyStr;

      if (existingKey != null) {
        privateKeyStr = existingKey;
        final recoveryKey = await WalletStorage.getLocallyStoredRecoveryKey();
        if (recoveryKey == null) {
          await _setupRecovery(privateKeyStr);
        }
      } else {
        privateKeyStr = generatePrivateKey().toString();
        final wif = fromPrivateKeyStrToWIF(privateKeyStr);
        await WalletStorage.storePrivateKey(privateKeyToWIF(wif));
        await _setupRecovery(privateKeyStr);
      }

      final privKey = wifToPrivateKey(privateKeyStr);

      _pubKey = getCompressedPublicKey(privKey);
      _addressTestnet = getStacksAddress(_pubKey, testnet: true);
      _addressMainnet = getStacksAddress(_pubKey, testnet: false);
    } catch (e, stack) {
      debugPrint("Erreur lors de l'initialisation du wallet : $e");
      debugPrint("$stack");
      rethrow; // Ou affiche un message user-friendly si en prod
    }
  }

  String get addressTestnet => _addressTestnet;
  String get addressMainnet => _addressMainnet;
  Future<String?> get wif => WalletStorage.getPrivateKey();

  Uint8List get publicKey => _pubKey;
  Future<ECPrivateKey> get privateKey async => wifToPrivateKey(wif as String);
}

// static const _backend = WalletBackend();
// Processus complet
Future<String> generateRecoveryKey(String userId) async {
  if (await _isCompromisedDevice()) {
    return "Appareil compromis, accès refusé.";
  }

  var privateKey = await WalletStorage
      .getPrivateKey(); // Toujours retourner la clé existante ou nouvellement créée

  if (privateKey == null) {
    throw Exception("Le compte n'a aucune clé privé");
  }
  return await _setupRecovery(privateKey);
}

// Mise en place de la clé de récupération et recoveryKey
Future<String> _setupRecovery(String privateKey) async {
  final recoveryKey = generatePrivateKey();
  final xorKey = xorKeys(privateKey, recoveryKey.d as String);

  try {
    await postRecoveryKey(xorKey);
    await WalletStorage.storeRecoveryKeyLocally(recoveryKey as String);
    return recoveryKey as String;
  } catch (e) {
    debugPrint("Erreur lors de l'envoi de la recovery key : $e");
    rethrow;
  }
}

Future<String> getRecoveryKey() async {
  if (await _isCompromisedDevice()) {
    return "Appareil compromis, accès refusé.";
  }
  var recoveryKey = await WalletStorage
      .getLocallyStoredRecoveryKey(); // Toujours retourner la clé existante ou nouvellement créée

  if (recoveryKey == null) {
    throw Exception("Appareil non sécurisé. Aucune de clé de récupération.");
  }
  return recoveryKey;
}

Future<String> getPrivateKey() async {
  if (await _isCompromisedDevice()) {
    return "Appareil compromis, accès refusé.";
  }

  var privateKey = await WalletStorage
      .getPrivateKey(); // Toujours retourner la clé existante ou nouvellement créée

  if (privateKey == null) {
    privateKey = generatePrivateKey() as String;
    await WalletStorage.storePrivateKey(privateKey);
    await _setupRecovery(privateKey);
  }
  return privateKey;
}

// Vérification si l'appareil est rooté/jailbreaké
Future<bool> _isCompromisedDevice() async {
  // En mode debug, on ignore cette vérification
  if (kDebugMode) {
    return false; // On simule un appareil "non compromis" en debug
  }

  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;
  return androidInfo.isPhysicalDevice == false;
}
