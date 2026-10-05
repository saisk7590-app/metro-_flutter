import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'http_client_runner_stub.dart'
    if (dart.library.io) 'http_client_runner_io.dart';

void initHttpClient() {
  initAppHttpClient();
}

void runAppWithHttpClient(Widget app) {
  runAppWithConfiguredHttpClient(app);
}

http.Client getAppHttpClient() {
  return createPlatformHttpClient();
}
