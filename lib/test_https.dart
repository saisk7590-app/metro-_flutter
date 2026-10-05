import 'http_client_runner.dart';

Future<String> testHttpsConnection() async {
  const url =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login';

  try {
    final response = await getAppHttpClient().post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: '{}',
    );

    return '''
SUCCESS
Status: ${response.statusCode}

Response:
${response.body}
''';
  } catch (e) {
    return '''
ERROR

$e
''';
  }
}
