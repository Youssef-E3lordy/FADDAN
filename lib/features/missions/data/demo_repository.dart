import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/mission.dart';
import 'mission_dto.dart';

class DemoMissionRepository implements MissionRepository {
  @override
  Future<List<Mission>> load() async =>
      (jsonDecode(await rootBundle.loadString('assets/fixtures/missions.json'))
              as List)
          .map((j) => MissionDto.parse(Map<String, dynamic>.from(j as Map)))
          .toList();
}
