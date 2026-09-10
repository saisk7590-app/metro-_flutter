import 'package:flutter/material.dart';

import 'http_client_runner_stub.dart'
    if (dart.library.io) 'http_client_runner_io.dart';

void runAppWithHttpClient(Widget app) {
  runAppWithConfiguredHttpClient(app);
}
