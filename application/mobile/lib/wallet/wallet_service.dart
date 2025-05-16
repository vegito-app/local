import 'package:car2go/wallet/crypto/clarity.dart';
import 'package:car2go/wallet/crypto/stacks.dart';
import 'package:car2go/wallet/crypto/wif.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:hex/hex.dart';
import 'package:pointycastle/ecc/api.dart';

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
      final existingKeyWIF = await WalletStorage.getPrivateKey();
      if (existingKeyWIF != null) {
        final recoveryKey = await WalletStorage.getLocallyStoredRecoveryKey();
        if (recoveryKey == null) {
          await _setupRecovery(existingKeyWIF);
        }
      } else {
        final privateKey = generatePrivateKey();
        final privateKeyWIF = privateKeyToWIF(privateKey);
        await WalletStorage.storePrivateKey(privateKeyWIF);
        await _setupRecovery(privateKeyWIF);
      }
      if (existingKeyWIF == null) {
        throw Exception('required WIF for computing wallet public keys');
      }
      final privKey = wifToPrivateKey(existingKeyWIF);
      _pubKey = getCompressedPublicKey(privKey);
      final addressTestnet = getStacksAddress(_pubKey, testnet: true);
      if (!isValidStacksAddress(addressTestnet, testnet: true)) {
        throw Exception('computing Stacks Testnet Address not valid');
      }
      _addressTestnet = addressTestnet;
      final addressMainnet = getStacksAddress(_pubKey, testnet: false);
      if (!isValidStacksAddress(addressMainnet, testnet: false)) {
        throw Exception('computing Stacks Mainnet Address not valid');
      }
      _addressMainnet = addressMainnet;
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

  var wif = await WalletStorage
      .getPrivateKey(); // Toujours retourner la clé existante ou nouvellement créée

  if (wif == null) {
    throw Exception("Le compte n'a aucune clé privé");
  }
  return await _setupRecovery(wif);
}

// Mise en place de la clé de récupération et recoveryKey
Future<String> _setupRecovery(String privateKey) async {
  final recoveryKey = privateKeyToWIF(generatePrivateKey());
  final xorKey = xorWIFkeys(privateKey, recoveryKey);
  try {
    await postRecoveryKey(xorKey);
    await WalletStorage.storeRecoveryKeyLocally(recoveryKey);
    return recoveryKey;
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

Future<String> getPrivateKeyWIF() async {
  if (await _isCompromisedDevice()) {
    return "Appareil compromis, accès refusé.";
  }
  var privateKeyWIF = await WalletStorage.getPrivateKey();

  if (privateKeyWIF == null) {
    final privateKey = generatePrivateKey();
    privateKeyWIF = privateKeyToWIF(privateKey, testnet: true);
    await WalletStorage.storePrivateKey(privateKeyWIF);
    await _setupRecovery(privateKeyWIF);
  }
  return privateKeyWIF;
}

Future<String> signAndBroadCast(ContractCall tx) async {
  if (await _isCompromisedDevice()) {
    throw Exception("Appareil compromis, signature refusée.");
  }

  final privKeyWIF = await WalletStorage.getPrivateKey();
  if (privKeyWIF == null) {
    throw Exception("Aucune clé privée trouvée pour signer.");
  }

  final privKey = wifToPrivateKey(privKeyWIF);
  final message = tx.serialize();
  final signature = signMessage(message, privKey);

  // Ici, la diffusion est simulée.
  // Dans une vraie app, on appellerait un backend ou une API RPC Stacks
  debugPrint("Transaction signée: $message");
  debugPrint("Signature DER: ${HEX.encode(signature)}");

  // Retourner un hash fictif de la tx pour l'instant
  final txId = sha256.convert(signature).toString();
  return txId;
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
