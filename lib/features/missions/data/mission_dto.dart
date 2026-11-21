import '../domain/mission.dart';

double number(dynamic v, [double fallback = 0]) =>
    v is num && v.isFinite ? v.toDouble() : fallback;
double? optionalNumber(dynamic v) =>
    v is num && v.isFinite ? v.toDouble() : null;

class MissionDto {
  static Map<String, dynamic> encode(Mission m) => {
    'mission_id': m.id,
    'farm_id': m.farmId,
    'greenhouse_id': m.greenhouseId,
    'farm_name': m.farmName,
    'row_number': m.row,
    'row_length_cm': m.length,
    'covered_distance_cm': m.covered,
    'start_time': m.started.toIso8601String(),
    'robot_battery_level_pct': m.battery,
    'tank_level_ml': m.tank,
    'avg_temp_c': m.temperature,
    'avg_humidity_pct': m.humidity,
    'total_dosage_sprayed_ml': m.actualMl,
    'conventional_blanket_estimate_ml': m.baselineMl,
    'heatmap_points': m.points
        .map(
          (d) => {
            'detection_id': d.id,
            'distance_from_row_start_cm': d.distance,
            'disease_name': d.disease,
            'infection_percentage': d.infection,
            'confidence_score': d.confidence,
            'dosage_amount_ml': d.dosage,
            'spray_status': d.sprayed,
            'approval_status': d.approval,
            'pesticide_type': d.pesticide,
            'image_url': d.imageUrl,
            'safe_harvest_date': d.safeHarvestDate?.toIso8601String(),
          },
        )
        .toList(),
  };

  static Mission parse(Map<String, dynamic> j) => Mission(
    id: j['mission_id'] as String,
    farmId: (j['farm_id'] as num).toInt(),
    greenhouseId: (j['greenhouse_id'] as num).toInt(),
    farmName: j['farm_name'] as String? ?? 'Farm ${j['farm_id']}',
    row: (j['row_number'] as num).toInt(),
    length: number(j['row_length_cm']),
    covered: number(j['covered_distance_cm']),
    started: DateTime.parse(j['start_time'] as String).toUtc(),
    battery: optionalNumber(j['robot_battery_level_pct']),
    tank: optionalNumber(j['tank_level_ml']),
    temperature: optionalNumber(j['avg_temp_c']),
    humidity: optionalNumber(j['avg_humidity_pct']),
    actualMl: number(j['total_dosage_sprayed_ml']),
    baselineMl: number(j['conventional_blanket_estimate_ml']),
    points: ((j['heatmap_points'] as List?) ?? [])
        .map((p) => detection(Map<String, dynamic>.from(p as Map)))
        .toList(),
  );
  static Detection detection(Map<String, dynamic> p) => Detection(
    id: p['detection_id'] as String,
    distance: number(p['distance_from_row_start_cm']),
    disease: p['disease_name'] as String? ?? 'Unknown',
    infection: number(p['infection_percentage']),
    confidence: number(p['confidence_score']),
    dosage: number(p['dosage_amount_ml']),
    sprayed: p['spray_status'] == true,
    approval: p['approval_status'] as String? ?? 'Unknown',
    pesticide: p['pesticide_type'] as String?,
    imageUrl: p['image_url'] as String?,
    safeHarvestDate: DateTime.tryParse(p['safe_harvest_date'] as String? ?? ''),
  );
}
