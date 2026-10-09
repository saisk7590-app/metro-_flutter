import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    SecurityContext? ctx = context;
    if (ctx == null) {
      try {
        ctx = SecurityContext(withTrustedRoots: true);
      } catch (_) {
        ctx = SecurityContext.defaultContext;
      }
    }
    try {
      ctx.allowLegacyUnsafeRenegotiation = true;
    } catch (e) {
      debugPrint('Error enabling allowLegacyUnsafeRenegotiation in HttpOverrides: $e');
    }

    final client = super.createHttpClient(ctx);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return client;
  }
}

http.Client createPlatformHttpClient() {
  SecurityContext? ctx;
  try {
    ctx = SecurityContext(withTrustedRoots: true);
    ctx.allowLegacyUnsafeRenegotiation = true;
  } catch (e) {
    try {
      ctx = SecurityContext.defaultContext;
      ctx.allowLegacyUnsafeRenegotiation = true;
    } catch (_) {}
  }

  final httpClient = HttpClient(context: ctx);
  httpClient.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;

  return IOClient(httpClient);
}

void initAppHttpClient() {
  try {
    HttpOverrides.global = AppHttpOverrides();
  } catch (e) {
    debugPrint('Error setting HttpOverrides.global: $e');
  }

  try {
    SecurityContext.defaultContext.allowLegacyUnsafeRenegotiation = true;
  } catch (_) {}
}

void runAppWithConfiguredHttpClient(Widget app) {
  initAppHttpClient();
  http.runWithClient(() => runApp(app), () {
    return createPlatformHttpClient();
  });
}
