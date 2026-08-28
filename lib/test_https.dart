import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

Future<void> testHttpsConnection() async {
  const url =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login';

  try {
    debugPrint('Testing HTTPS connection...');

    final response = await http.get(
      Uri.parse(url),
    );

    debugPrint('STATUS: ${response.statusCode}');
    debugPrint('BODY: ${response.body}');
  } catch (e) {
    debugPrint('HTTPS ERROR: $e');
  }
}