import 'dart:convert';
import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import '../http_client_runner.dart';

/// Base API service providing HTTP helpers, token management, and base URLs.
abstract class BaseApiService {
  static const String baseUrl =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetregister/api';
  static const String assetConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/assetconfig/api';
  static const String maintenanceConfigBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/maintenanceconfig/api';
  static const String workOrderBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/workorderservice/api';
  static const String messagingBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/messaging/api';
  static const String adminBase =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api';

  static String? currentToken;
  static String? currentUserSession;
  static String? currentRoleId;

  static http.Client get client => getAppHttpClient();

  static String sanitizeToken(String raw) {
    var clean = raw.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '').trim();
    if (clean.contains('k&gF=')) {
      clean = clean.replaceFirst(RegExp(r'k&gF=(?=.{8}$)'), '');
    }
    if (clean.contains('&gF=')) {
      clean = clean.split('&gF=').first;
    }
    return clean;
  }

  /// Checks if a JWT token has expired by inspecting the 'exp' claim.
  static bool isTokenExpired(String? token) {
    if (token == null || token.trim().isEmpty) return true;
    try {
      final clean = sanitizeToken(token);
      final parts = clean.split('.');
      if (parts.length < 2) return true;
      var payload = parts[1];
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decodedJson = utf8.decode(base64.decode(payload));
      final map = jsonDecode(decodedJson);
      if (map is Map<String, dynamic> && map['exp'] != null) {
        final expSeconds = map['exp'] as int;
        final expiryTime = DateTime.fromMillisecondsSinceEpoch(expSeconds * 1000);
        return DateTime.now().isAfter(expiryTime);
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> postJson(
    String endpoint, {
    String base = '',
    dynamic body,
    Map<String, String>? headers,
  }) async {
    final targetBase = base.isNotEmpty ? base : baseUrl;
    final uri = Uri.parse('$targetBase$endpoint');

    final jsonBody = body == null ? '' : jsonEncode(body);
    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode(jsonBody)).toString();

    final effectiveHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Hash-Check': hashCheck,
    };

    final rawToken = headers?['Authorization'] ?? currentToken;
    if (rawToken != null && rawToken.isNotEmpty) {
      final jwtToken = sanitizeToken(rawToken);
      effectiveHeaders['Authorization'] = 'Bearer $jwtToken';
    }

    final roleId = headers?['Role-Id'] ?? headers?['Role-id'] ?? currentRoleId ?? '1';
    effectiveHeaders['Role-Id'] = roleId;

    final session = headers?['userSession'] ?? currentUserSession;
    if (session != null && session.isNotEmpty) {
      effectiveHeaders['userSession'] = session;
    }

    if (headers != null) {
      headers.forEach((key, value) {
        final lower = key.toLowerCase();
        if (lower != 'authorization' &&
            lower != 'origin' &&
            lower != 'referer' &&
            lower != 'hash-check' &&
            lower != 'role-id' &&
            lower != 'usersession') {
          effectiveHeaders[key] = value;
        }
      });
    }

    return await client.post(
      uri,
      headers: effectiveHeaders,
      body: body == null ? null : jsonBody,
    );
  }

  Future<http.Response> getJson(
    String endpoint, {
    String base = '',
    Map<String, String>? headers,
  }) async {
    final targetBase = base.isNotEmpty ? base : baseUrl;
    final uri = Uri.parse('$targetBase$endpoint');

    final hashCheck = crypto.Hmac(
      crypto.sha256,
      utf8.encode('UW1nF0cu5S'),
    ).convert(utf8.encode('null')).toString();

    final effectiveHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json, text/plain, */*',
      'Hash-Check': hashCheck,
    };

    final rawToken = headers?['Authorization'] ?? currentToken;
    if (rawToken != null && rawToken.isNotEmpty) {
      final jwtToken = sanitizeToken(rawToken);
      effectiveHeaders['Authorization'] = 'Bearer $jwtToken';
    }

    final roleId = headers?['Role-Id'] ?? headers?['Role-id'] ?? currentRoleId ?? '1';
    effectiveHeaders['Role-Id'] = roleId;

    final session = headers?['userSession'] ?? currentUserSession;
    if (session != null && session.isNotEmpty) {
      effectiveHeaders['userSession'] = session;
    }

    if (headers != null) {
      headers.forEach((key, value) {
        final lower = key.toLowerCase();
        if (lower != 'authorization' &&
            lower != 'origin' &&
            lower != 'referer' &&
            lower != 'hash-check' &&
            lower != 'role-id' &&
            lower != 'usersession') {
          effectiveHeaders[key] = value;
        }
      });
    }

    return await client.get(
      uri,
      headers: effectiveHeaders,
    );
  }

  List<dynamic> normalizeListResponse(dynamic responseBody) {
    if (responseBody is List) return responseBody;

    if (responseBody is String) {
      try {
        return normalizeListResponse(jsonDecode(responseBody));
      } catch (_) {
        return <dynamic>[];
      }
    }

    if (responseBody is Map<String, dynamic>) {
      for (final key in [
        'results',
        'result',
        'data',
        'items',
        'list',
        'values',
      ]) {
        final value = responseBody[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          final nested = normalizeListResponse(value);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return <dynamic>[];
  }
}
