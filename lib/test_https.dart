import 'package:http/http.dart' as http;

Future<String> testHttpsConnection() async {
  const url =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login';

  try {
    final response = await http.post(
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
