// Wallet Import Format (WIF)
import 'dart:typed_data' show Uint8List;

import 'package:bs58/bs58.dart' show base58;
import 'package:car2go/wallet/crypto/typed_data.dart';
import 'package:crypto/crypto.dart' show sha256;
import 'package:hex/hex.dart' show HEX;
import 'package:pointycastle/ecc/api.dart' show ECPrivateKey;
import 'package:pointycastle/ecc/curves/secp256k1.dart' show ECCurve_secp256k1;

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
  final d = HEX.encode(privKeyBytes);
  return fromPrivateKeyStrToWIF(d);
}

ECPrivateKey fromPrivateKeyStrToWIF(String privateKeyStr) {
  return ECPrivateKey(
      BigInt.parse(privateKeyStr, radix: 16), ECCurve_secp256k1());
}

String privateKeyStrToWIF(String privateKeyStr,
    {bool compressed = true, bool testnet = true}) {
  return privateKeyToWIF(fromPrivateKeyStrToWIF(privateKeyStr));
}

String privateKeyToWIF(ECPrivateKey privKey,
    {bool compressed = true, bool testnet = true}) {
  final prefix = testnet ? 0xEF : 0x80;
  final privKeyBytes = bigIntToBytes(privKey.d!, 32);
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
