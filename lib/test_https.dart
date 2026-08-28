import 'package:http/http.dart' as http;

Future<String> testHttpsConnection() async {
  const url =
      'https://nxamsdev.winfocus.co.in/NxAmsDevServices/adminService/api/Admin/login';

  try {
    final response = await http.get(
      Uri.parse(url),
    );

    return 'SUCCESS\nStatus: ${response.statusCode}\n\n${response.body}';
  } catch (e) {
    return 'ERROR\n\n$e';
  }
}