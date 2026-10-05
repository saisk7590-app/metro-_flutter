import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void initAppHttpClient() {}

void runAppWithConfiguredHttpClient(Widget app) {
  runApp(app);
}

http.Client createPlatformHttpClient() {
  return http.Client();
}
