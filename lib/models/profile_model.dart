class StaffProfileModel {
  final int staffId;
  final String title;
  final String staffName;
  final String firstName;
  final String lastName;
  final String staffNo;
  final String unitCode;
  final int unitId;
  final String unitName;
  final String locationName;
  final String designationName;
  final int designationId;
  final String mobile;
  final String email;
  final String gender;
  final String address;
  final String status;
  final String skill;
  final String vendorName;
  final String staffTypeName;

  StaffProfileModel({
    required this.staffId,
    this.title = '',
    required this.staffName,
    this.firstName = '',
    this.lastName = '',
    this.staffNo = '',
    this.unitCode = '',
    this.unitId = 0,
    this.unitName = '',
    this.locationName = '',
    this.designationName = '',
    this.designationId = 0,
    this.mobile = '',
    this.email = '',
    this.gender = '',
    this.address = '',
    this.status = '',
    this.skill = '',
    this.vendorName = '',
    this.staffTypeName = '',
  });

  factory StaffProfileModel.fromJson(Map<String, dynamic> json) {
    return StaffProfileModel(
      staffId: json['staffId'] is int
          ? json['staffId']
          : int.tryParse(json['staffId']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      staffName: json['staffName']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      staffNo: json['staffNo']?.toString() ?? '',
      unitCode: json['unitCode']?.toString() ?? '',
      unitId: json['unitId'] is int
          ? json['unitId']
          : int.tryParse(json['unitId']?.toString() ?? '') ?? 0,
      unitName: json['unitName']?.toString() ?? '',
      locationName: json['locationName']?.toString() ?? '',
      designationName: (json['designatioName'] ?? json['designationName'])?.toString() ?? '',
      designationId: json['designationId'] is int
          ? json['designationId']
          : int.tryParse(json['designationId']?.toString() ?? '') ?? 0,
      mobile: json['mobile']?.toString() ?? '',
      email: (json['eMail'] ?? json['email'])?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      skill: json['skill']?.toString() ?? '',
      vendorName: json['vendorName']?.toString() ?? '',
      staffTypeName: json['staffTypeName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'staffId': staffId,
      'title': title,
      'staffName': staffName,
      'firstName': firstName,
      'lastName': lastName,
      'staffNo': staffNo,
      'unitCode': unitCode,
      'unitId': unitId,
      'unitName': unitName,
      'locationName': locationName,
      'designatioName': designationName,
      'designationId': designationId,
      'mobile': mobile,
      'eMail': email,
      'gender': gender,
      'address': address,
      'status': status,
      'skill': skill,
      'vendorName': vendorName,
      'staffTypeName': staffTypeName,
    };
  }
}
