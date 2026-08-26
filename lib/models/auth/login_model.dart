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
  final String? mfaReferenceCode;
  final String captchaId;
  final String captchaImage;
  final String token;

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
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      id: json['id'],
      userName: json['userName'],
      staffId: json['staffId'],
      staffName: json['staffName'],
      userSession: json['userSession'],
      userSessionId: json['userSessionId'],
      lastLogin: json['lastLogin'],
      unitId: json['unitId'],
      unitName: json['unitName'],
      roleIds: json['roleIds'],
      roleNames: json['roleNames'],
      assetCategoryId: json['assetCategoryId'],
      unitAccessScopes: json['unitAccessScopes'],
      loginResult: json['loginResult'],
      loginMessage: json['loginMessage'],
      resetpwd: json['resetpwd'],
      locationName: json['locationName'],
      isMFARequired: json['isMFARequired'],
      mfaReferenceCode: json['mfaReferenceCode'],
      captchaId: json['captchaId'],
      captchaImage: json['captchaImage'],
      token: json['token'],
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
    final jsonString = jsonEncode(toJson());
    return base64Encode(utf8.encode(jsonString));
  }

  String get bearerToken {
    return token.split('&gF=').first;
  }
}
