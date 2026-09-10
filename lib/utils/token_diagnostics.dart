import 'dart:convert';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter/foundation.dart';

void logTokenDiagnostics(String stage, String token) {
  final fingerprint = crypto.sha256
      .convert(utf8.encode(token))
      .toString()
      .substring(0, 12);

  debugPrint(
    'Token [$stage]: fingerprint=$fingerprint '
    'length=${token.length} '
    'parts=${token.split('.').length} '
    'hasGf=${token.contains('&gF=')}',
  );
}
