// ignore_for_file: unused_shown_name

import 'dart:typed_data';

import 'package:bs58/bs58.dart' show base58;
import 'package:car2go/wallet/crypto/c32check.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:dartsv/dartsv.dart'
    show
        Address,
        NetworkType,
        SVPrivateKey,
        SVPublicKey,
        SVSignature,
        ripemd160;
import 'package:hex/hex.dart';
import 'package:pointycastle/export.dart';

// ----------- Génère une clé privée secp256k1 -----------
ECPrivateKey generatePrivateKey() {
  final keyParams = ECKeyGeneratorParameters(ECCurve_secp256k1());
  final keyGen = ECKeyGenerator();
  final secureRandom = FortunaRandom();

  secureRandom
      .seed(KeyParameter(Uint8List.fromList(List.generate(32, (i) => i + 1))));
  keyGen.init(ParametersWithRandom(keyParams, secureRandom));
  final pair = keyGen.generateKeyPair();
  return pair.privateKey as ECPrivateKey;
}

// ----------- Clé publique compressée -----------
Uint8List getCompressedPublicKey(ECPrivateKey privKey) {
  final pubPoint = (ECCurve_secp256k1().G * privKey.d)!;
  final x = pubPoint.x!.toBigInteger()!;
  final y = pubPoint.y!.toBigInteger()!;
  final prefix = y.isEven ? 0x02 : 0x03;
  final xBytes = _bigIntToBytes(x, 32);
  return Uint8List.fromList([prefix, ...xBytes]);
}

// ----------- Adresse STX à partir de la pubkey -----------
String getStacksAddress(Uint8List pubKey, {bool testnet = true}) {
  final hash160 = ripemd160(sha256.convert(pubKey).bytes);
  var version = testnet ? 0x16 : 0x1A; // ST = testnet, SP = mainnet
  final versionedPayload = [version, ...hash160];

  final checksum = sha256
      .convert(sha256.convert(Uint8List.fromList(versionedPayload)).bytes)
      .bytes
      .sublist(0, 4);
  final fullPayload = Uint8List.fromList([...versionedPayload, ...checksum]);
  // return base32.encode(fullPayload).replaceAll('=', '');
  return c32Encode(fullPayload, version: version);
}

// ----------- Utilitaires -----------
Uint8List _bigIntToBytes(BigInt value, int size) {
  final result = Uint8List(size);
  final bytes =
      value.toUnsigned(size * 8).toRadixString(16).padLeft(size * 2, '0');
  final byteList = HEX.decode(bytes);
  result.setRange(size - byteList.length, size, byteList);
  return result;
}

// ----------- Exemple d'utilisation -----------
void main() {
  final privKey = generatePrivateKey();
  final privKeyHex = HEX.encode(_bigIntToBytes(privKey.d!, 32));
  print('Clé privée : $privKeyHex');

  final pubKey = getCompressedPublicKey(privKey);
  final pubKeyHex = HEX.encode(pubKey);
  print('Clé publique compressée : $pubKeyHex');

  final addressTestnet = getStacksAddress(pubKey, testnet: true);
  print('Adresse STX (testnet): $addressTestnet');
  print('VALIDE : ${isValidStacksAddress(addressTestnet, testnet: true)}');

  final addressMainnet = getStacksAddress(pubKey, testnet: false);
  print('Adresse STX (mainnet): $addressMainnet');
  print('VALIDE : ${isValidStacksAddress(addressMainnet, testnet: false)}');

  const message = 'Je suis un message signé';
  final signature = signMessage(message, privKey);
  print('Signature DER : ${HEX.encode(signature)}');

  final isValid = verifySignature(message, signature, pubKey);
  print('Signature valide : $isValid');

  final wif = privateKeyToWIF(privKey, testnet: true);
  print('Clé privée WIF : $wif');

  final fromWif = wifToPrivateKey(wif);
  final pubFromWif = getCompressedPublicKey(fromWif);
  print('Clé publique extraite du WIF : ${HEX.encode(pubFromWif)}');
}

bool isValidStacksAddress(String address, {bool testnet = false}) {
  try {
    final decoded = c32Decode(address);
    final version = decoded["version"];

    // Vérifie la version selon le réseau
    if (testnet && version != 0x16) return false;
    if (!testnet && version != 0x1A) return false;

    return true;
  } catch (e) {
    // Si une erreur est levée, l'adresse est invalide
    return false;
  }
}

Uint8List signMessage(String message, ECPrivateKey privKey) {
  final signer = Signer("SHA-256/ECDSA");

  final secureRandom = FortunaRandom();
  secureRandom.seed(KeyParameter(Uint8List.fromList(List.generate(
      32,
      (i) =>
          i + 1)))); // même seed que pour la clé, à remplacer si usage en prod

  final privParams = ParametersWithRandom(
    PrivateKeyParameter<ECPrivateKey>(privKey),
    secureRandom,
  );
  signer.init(true, privParams);

  final messageBytes = Uint8List.fromList(message.codeUnits);
  final sig = signer.generateSignature(messageBytes) as ECSignature;

  return _encodeSignatureDER(sig);
}

Uint8List _encodeSignatureDER(ECSignature sig) {
  Uint8List _encodeInt(BigInt i) {
    final raw = i.toRadixString(16).padLeft(2, '0');
    final b = HEX.decode(raw.length % 2 == 1 ? '0$raw' : raw);
    return (b[0] & 0x80) != 0
        ? Uint8List.fromList([0x00, ...b])
        : Uint8List.fromList(b);
  }

  final r = _encodeInt(sig.r);
  final s = _encodeInt(sig.s);

  final sequence = <int>[
    0x02,
    r.length,
    ...r,
    0x02,
    s.length,
    ...s,
  ];

  return Uint8List.fromList([
    0x30,
    sequence.length,
    ...sequence,
  ]);
}

bool verifySignature(
    String message, Uint8List signatureDER, Uint8List compressedPubKey) {
  final curve = ECCurve_secp256k1();

  final prefix = compressedPubKey[0];
  final xBytes = compressedPubKey.sublist(1);
  final x = BigInt.parse(HEX.encode(xBytes), radix: 16);
  final xFieldElement = curve.curve.fromBigInteger(x);

  // y^2 = x^3 + ax + b
  final alpha = xFieldElement * xFieldElement * xFieldElement +
      curve.curve.a! * xFieldElement +
      curve.curve.b!;
  final beta = alpha.sqrt();

  if (beta == null) {
    throw ArgumentError('Impossible de calculer la racine carrée de y²');
  }
  final betaInteger = beta.toBigInteger();
  if (betaInteger == null) {
    throw ArgumentError(
        'Impossible de calculer un entier pour la racine carrée de y²');
  }
  final isYOdd = betaInteger.isOdd;
  final isPrefixOdd = prefix == 0x03;
  final y = (isYOdd == isPrefixOdd) ? beta : -beta;
  final yInteger = y.toBigInteger();
  if (yInteger == null) {
    throw ArgumentError(
        'Impossible d\'inverser la valeur de la racine carrée de y²');
  }
  final point = curve.curve.createPoint(x, yInteger);
  final pubKey = ECPublicKey(point, curve);

  final signer = Signer("SHA-256/ECDSA");
  signer.init(false, PublicKeyParameter(pubKey));

  final sig = _decodeSignatureDER(signatureDER);
  final messageBytes = Uint8List.fromList(message.codeUnits);
  return signer.verifySignature(messageBytes, sig);
}

ECSignature _decodeSignatureDER(Uint8List der) {
  if (der[0] != 0x30) throw ArgumentError('Signature DER invalide');
  int rLen = der[3];
  int sLen = der[5 + rLen];
  final r = BigInt.parse(HEX.encode(der.sublist(4, 4 + rLen)), radix: 16);
  final s = BigInt.parse(HEX.encode(der.sublist(6 + rLen, 6 + rLen + sLen)),
      radix: 16);
  return ECSignature(r, s);
}

// Wallet Import Format (WIF)
ECPrivateKey wifToPrivateKey(String wif) {
  final decoded = base58.decode(wif);
  if (decoded.length != 37 && decoded.length != 38) {
    throw ArgumentError('Longueur invalide pour une clé WIF');
  }
  final checksum = decoded.sublist(decoded.length - 4);
  final payload = decoded.sublist(0, decoded.length - 4);
  final validChecksum =
      sha256.convert(sha256.convert(payload).bytes).bytes.sublist(0, 4);
  if (!checksum.asMap().entries.every((e) => e.value == validChecksum[e.key])) {
    throw ArgumentError('Checksum WIF invalide');
  }
  final compressed = payload.length == 34 && payload.last == 0x01;
  final privKeyBytes = compressed ? payload.sublist(1, 33) : payload.sublist(1);
  final d = BigInt.parse(HEX.encode(privKeyBytes), radix: 16);
  return ECPrivateKey(d, ECCurve_secp256k1());
}

String privateKeyToWIF(ECPrivateKey privKey,
    {bool compressed = true, bool testnet = true}) {
  final prefix = testnet ? 0xEF : 0x80;
  final privKeyBytes = _bigIntToBytes(privKey.d!, 32);
  final payload = [prefix, ...privKeyBytes];
  if (compressed) {
    payload.add(0x01);
  }
  final checksum = sha256
      .convert(sha256.convert(Uint8List.fromList(payload)).bytes)
      .bytes
      .sublist(0, 4);
  final fullPayload = Uint8List.fromList([...payload, ...checksum]);
  // return base58.encode(fullPayload);
  return base58.encode(fullPayload);
}
