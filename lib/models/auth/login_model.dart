import 'dart:convert';

class LoginModel {
  final int id;
  final String userName;
  final int staffId;
  final String staffName;
  final String userSession;
  final int userSessionId;
  final String lastLogin;
  final int unitId;
  final String unitName;
  final String roleIds;
  final String roleNames;
  final int assetCategoryId;
  final String unitAccessScopes;
  final int loginResult;
  final String loginMessage;
  final int resetpwd;
  final String locationName;
  final int isMFARequired;
  String? mfaReferenceCode;
  final String captchaId;
  final String captchaImage;
  final String token;
  final String? rawBody;

  LoginModel({
    required this.id,
    required this.userName,
    required this.staffId,
    required this.staffName,
    required this.userSession,
    required this.userSessionId,
    required this.lastLogin,
    required this.unitId,
    required this.unitName,
    required this.roleIds,
    required this.roleNames,
    required this.assetCategoryId,
    required this.unitAccessScopes,
    required this.loginResult,
    required this.loginMessage,
    required this.resetpwd,
    required this.locationName,
    required this.isMFARequired,
    this.mfaReferenceCode,
    required this.captchaId,
    required this.captchaImage,
    required this.token,
    this.rawBody,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json, {String? rawBody}) {
    return LoginModel(
      id: json['id'] ?? 0,
      userName: json['userName'] ?? '',
      staffId: json['staffId'] ?? 0,
      staffName: json['staffName'] ?? '',
      userSession: json['userSession'] ?? '',
      userSessionId: json['userSessionId'] ?? 0,
      lastLogin: json['lastLogin'] ?? '',
      unitId: json['unitId'] ?? 0,
      unitName: json['unitName'] ?? '',
      roleIds: json['roleIds'] ?? '',
      roleNames: json['roleNames'] ?? '',
      assetCategoryId: json['assetCategoryId'] ?? 0,
      unitAccessScopes: json['unitAccessScopes'] ?? '',
      loginResult: json['loginResult'] ?? 0,
      loginMessage: json['loginMessage'] ?? '',
      resetpwd: json['resetpwd'] ?? 0,
      locationName: json['locationName'] ?? '',
      isMFARequired: json['isMFARequired'] ?? 0,
      mfaReferenceCode: json['mfaReferenceCode'],
      captchaId: json['captchaId'] ?? '',
      captchaImage: json['captchaImage'] ?? '',
      token: json['token'] ?? '',
      rawBody: rawBody,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'staffId': staffId,
      'staffName': staffName,
      'userSession': userSession,
      'userSessionId': userSessionId,
      'lastLogin': lastLogin,
      'unitId': unitId,
      'unitName': unitName,
      'roleIds': roleIds,
      'roleNames': roleNames,
      'assetCategoryId': assetCategoryId,
      'unitAccessScopes': unitAccessScopes,
      'loginResult': loginResult,
      'loginMessage': loginMessage,
      'resetpwd': resetpwd,
      'locationName': locationName,
      'isMFARequired': isMFARequired,
      'mfaReferenceCode': mfaReferenceCode,
      'captchaId': captchaId,
      'captchaImage': captchaImage,
      'token': token,
    };
  }

  String get encodedUserSession {
    if (rawBody != null && rawBody!.isNotEmpty) {
      return base64Encode(utf8.encode(rawBody!));
    }
    final jsonString = jsonEncode(toJson());
    return base64Encode(utf8.encode(jsonString));
  }

  String get bearerToken {
    var clean = token.replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '').trim();
    if (clean.contains('k&gF=')) {
      clean = clean.replaceFirst(RegExp(r'k&gF=(?=.{8}$)'), '');
    }
    if (clean.contains('&gF=')) {
      clean = clean.split('&gF=').first;
    }
    return clean;
  }
}
