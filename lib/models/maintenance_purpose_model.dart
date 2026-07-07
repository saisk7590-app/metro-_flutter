class MaintenancePurposeModel {
  final int id;
  final String name;

  MaintenancePurposeModel({required this.id, required this.name});

  factory MaintenancePurposeModel.fromJson(Map<String, dynamic> json) {
    return MaintenancePurposeModel(id: json['id'], name: json['name']);
  }
}
