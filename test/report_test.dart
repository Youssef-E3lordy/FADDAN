import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:faddan/features/missions/data/mission_dto.dart';
import 'package:faddan/features/reports/export_report.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('PDF report builds from the same fixture as mission detail', () async {
    final rows = jsonDecode(
      await rootBundle.loadString('assets/fixtures/missions.json'),
    ) as List;
    final mission = MissionDto.parse(Map<String, dynamic>.from(rows.first));
    final bytes = await buildMissionReport(mission);
    expect(ascii.decode(bytes.take(4).toList()), '%PDF');
    expect(bytes.length, greaterThan(1000));
    final output = Platform.environment['FADDAN_SAMPLE_REPORT'];
    if (output != null) await File(output).writeAsBytes(bytes);
  });
}
