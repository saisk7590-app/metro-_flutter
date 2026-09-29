class TrainModel {
  final int id;
  final String no;

  TrainModel({required this.id, required this.no});

  factory TrainModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ??
        json['Id'] ??
        json['ts_id'] ??
        json['tsId'] ??
        json['train_set'] ??
        json['trainSet'] ??
        json['value'] ??
        0;

    final rawNo = json['no'] ??
        json['No'] ??
        json['ts_no'] ??
        json['tsNo'] ??
        json['train_no'] ??
        json['trainNo'] ??
        json['name'] ??
        json['label'] ??
        '';

    final parsedId = rawId is num
        ? rawId.toInt()
        : int.tryParse(rawId.toString()) ?? 0;

    final parsedNo = rawNo.toString().trim();

    return TrainModel(
      id: parsedId,
      no: parsedNo.isNotEmpty
          ? parsedNo
          : (parsedId > 0 ? 'TS-$parsedId' : ''),
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'no': no};
}

