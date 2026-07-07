class TrainModel {
  final int id;
  final String no;

  TrainModel({required this.id, required this.no});

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    return TrainModel(id: json['id'], no: json['no'] ?? '');
  }
}
