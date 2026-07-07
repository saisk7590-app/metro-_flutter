class StatusModel {
  final int id;
  final String name;

  StatusModel({required this.id, required this.name});

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(id: json['id'], name: json['name']);
  }
}
