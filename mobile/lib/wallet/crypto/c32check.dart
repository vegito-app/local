import 'dart:typed_data';

import 'package:pointycastle/api.dart' show Digest;

/// Alphabet utilisé pour le C32 (différent du base32 RFC 4648)
const String c32Alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
final Map<String, int> c32CharToValue = {
  for (var i = 0; i < c32Alphabet.length; i++) c32Alphabet[i]: i
};

/// Convertit des données binaires en une chaîne C32
String c32Encode(Uint8List data, {int version = 22}) {
  if (version < 0 || version > 31) {
    throw ArgumentError('Version must be between 0 and 31');
  }

  // Ajout du préfixe version comme un octet au début
  final versionByte = version & 0x1f;
  final versionedData = Uint8List(data.length + 1);
  versionedData[0] = versionByte;
  versionedData.setRange(1, versionedData.length, data);

  // Ajout d'un checksum de 4 octets SHA256 double hash
  final checksum = _sha256(_sha256(versionedData)).sublist(0, 4);
  final fullData = Uint8List.fromList([...versionedData, ...checksum]);

  // Convertir le tableau d’octets en entier binaire
  var intValue = BigInt.zero;
  for (final byte in fullData) {
    intValue = (intValue << 8) | BigInt.from(byte);
  }

  // Encodage base32 custom
  final output = StringBuffer();
  while (intValue > BigInt.zero) {
    final index = intValue.remainder(BigInt.from(32)).toInt();
    intValue = intValue >> 5;
    output.write(c32Alphabet[index]);
  }

  // Ajout des 'leading zeros' sous forme de '0'
  final leadingZeroCount = fullData.takeWhile((b) => b == 0).length;
  for (var i = 0; i < leadingZeroCount; i++) {
    output.write('0');
  }

  return output.toString().split('').reversed.join('');
}

/// Decode une adresse C32 vers ses données brutes + version
Map<String, dynamic> c32Decode(String c32String) {
  var intValue = BigInt.zero;
  for (final char in c32String.toUpperCase().split('')) {
    if (!c32CharToValue.containsKey(char)) {
      throw ArgumentError('Invalid character in C32 string: $char');
    }
    intValue =
        (intValue * BigInt.from(32)) + BigInt.from(c32CharToValue[char]!);
  }

  // Convertir en bytes (big endian)
  final bytes = <int>[];
  while (intValue > BigInt.zero) {
    bytes.insert(0, (intValue & BigInt.from(0xFF)).toInt());
    intValue = intValue >> 8;
  }

  if (bytes.length < 5) {
    throw ArgumentError('Invalid C32 string (too short)');
  }

  final data = Uint8List.fromList(bytes.sublist(0, bytes.length - 4));
  final checksum = bytes.sublist(bytes.length - 4);

  final expectedChecksum = _sha256(_sha256(data)).sublist(0, 4);
  if (!listEquals(expectedChecksum, checksum)) {
    throw ArgumentError('Checksum mismatch in C32 decode');
  }

  final version = data[0];
  final payload = data.sublist(1);

  return {
    'version': version,
    'payload': Uint8List.fromList(payload),
  };
}

/// Double SHA256 pour le checksum
Uint8List _sha256(Uint8List data) {
  final d = Digest('SHA-256');
  return d.process(data);
}

/// Comparaison sécurisée de listes
bool listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
