// Util
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CryptoService {
  static final _shared = CryptoService._sharedInstance();
  CryptoService._sharedInstance();
  factory CryptoService() => _shared;

  Digest hashString({required String value}) {
    final encodedValue = utf8.encode(value);
    final hash = md5.convert(encodedValue);
    return hash;
  }

  bool checkHash({
    required String value,
    required String hash,
  }) {
    return md5.convert(utf8.encode(value)).toString() == hash;
  }
}
