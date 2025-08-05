// ignore_for_file: unused_shown_name

import 'dart:typed_data';

import 'package:hex/hex.dart';

// ----------- Utilitaires -----------
Uint8List bigIntToBytes(BigInt value, int size) {
  final result = Uint8List(size);
  final bytes =
      value.toUnsigned(size * 8).toRadixString(16).padLeft(size * 2, '0');
  final byteList = HEX.decode(bytes);
  result.setRange(size - byteList.length, size, byteList);
  return result;
}
