class Allocation {
  final String trackId;
  final String trainNo;
  final String status;
  final String purpose;
  final String inwardTime;
  final String outwardTime;
  final bool outwardScheduled;
  final String remarks;

  Allocation({
    required this.trackId,
    required this.trainNo,
    required this.status,
    required this.purpose,
    required this.inwardTime,
    required this.outwardTime,
    required this.outwardScheduled,
    required this.remarks,
  });
}
