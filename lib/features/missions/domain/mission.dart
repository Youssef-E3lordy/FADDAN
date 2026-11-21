enum UserRole { owner, operator, agronomist }

extension RoleName on UserRole {
  String get label => switch (this) {
    UserRole.owner => 'Farm owner',
    UserRole.operator => 'Field operator',
    UserRole.agronomist => 'Agronomist',
  };
}

enum Severity { healthy, low, moderate, high }

Severity severityFor(double value) => value <= 0
    ? Severity.healthy
    : value < 15
    ? Severity.low
    : value <= 40
    ? Severity.moderate
    : Severity.high;

class Detection {
  const Detection({
    required this.id,
    required this.distance,
    required this.disease,
    required this.infection,
    required this.confidence,
    required this.dosage,
    required this.sprayed,
    required this.approval,
    this.pesticide,
    this.imageUrl,
    this.safeHarvestDate,
  });
  final String id, disease, approval;
  final double distance, infection, confidence, dosage;
  final bool sprayed;
  final String? pesticide, imageUrl;
  final DateTime? safeHarvestDate;
  Severity get severity => severityFor(infection);
  bool get needsReview => approval == 'PendingReview';
}

class Mission {
  const Mission({
    required this.id,
    required this.farmId,
    required this.greenhouseId,
    required this.farmName,
    required this.row,
    required this.length,
    required this.covered,
    required this.started,
    required this.battery,
    required this.tank,
    required this.temperature,
    required this.humidity,
    required this.actualMl,
    required this.baselineMl,
    required this.points,
  });
  final String id, farmName;
  final int farmId, greenhouseId, row;
  final double length, covered, actualMl, baselineMl;
  final DateTime started;
  final double? battery, tank, temperature, humidity;
  final List<Detection> points;
  double get progress => length <= 0 ? 0 : (covered / length).clamp(0, 1);
  double? get savings =>
      baselineMl <= 0 ? null : (1 - actualMl / baselineMl) * 100;
  int get pending => points.where((d) => d.needsReview).length;
}

abstract interface class MissionRepository {
  Future<List<Mission>> load();
}
