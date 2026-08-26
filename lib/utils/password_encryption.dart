import 'package:encrypt/encrypt.dart' as encrypt;

class PasswordEncryption {
  static const String _keyString =
      '12345678901234567890123456789012';

  static const String _ivString =
      '1234567890123456';

  static String encryptPassword(String password) {
    final key = encrypt.Key.fromUtf8(_keyString);
    final iv = encrypt.IV.fromUtf8(_ivString);

    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.cbc,
        padding: 'PKCS7',
      ),
    );

    final encrypted = encrypter.encrypt(
      password,
      iv: iv,
    );

    return encrypted.base64;
  }
}