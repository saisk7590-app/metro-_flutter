import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

void runAppWithConfiguredHttpClient(Widget app) {
  http.runWithClient(() => runApp(app), () {
    final securityContext = SecurityContext.defaultContext;
    securityContext.allowLegacyUnsafeRenegotiation = true;
    final httpClient = HttpClient(context: securityContext);

    httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
          return host == 'nxamsdev.winfocus.co.in';
        };

    return IOClient(httpClient);
  });
}
