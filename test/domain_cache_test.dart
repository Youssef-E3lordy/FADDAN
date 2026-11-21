import 'dart:convert';

import 'package:faddan/core/cache.dart';
import 'package:faddan/features/missions/data/mission_dto.dart';
import 'package:faddan/features/missions/domain/mission.dart';
import 'package:faddan/features/missions/presentation/app_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

class MemoryCache implements CacheStore {
  Map<String, dynamic>? value;
  bool fail = false;
  @override
  Map<String, dynamic>? read() => value;
  @override
  Future<void> save(Map<String, dynamic> v) async {
    if (fail) throw StateError('test storage failure');
    value = Map.from(v);
  }

  @override
  Future<void> clear() async => value = null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('severity thresholds match the agreed contract', () {
    expect(severityFor(0), Severity.healthy);
    expect(severityFor(0.1), Severity.low);
    expect(severityFor(14.99), Severity.low);
    expect(severityFor(15), Severity.moderate);
    expect(severityFor(40), Severity.moderate);
    expect(severityFor(40.01), Severity.high);
  });
  test('nonfinite and absent readings remain safe', () {
    expect(number(double.nan), 0);
    expect(optionalNumber(double.infinity), null);
    expect(optionalNumber(null), null);
  });
  test('fixture DTOs parse dates, readings and review status', () async {
    final raw = jsonDecode(
      await rootBundle.loadString('assets/fixtures/missions.json'),
    ) as List;
    final missions = raw
        .map((j) => MissionDto.parse(Map<String, dynamic>.from(j)))
        .toList();
    expect(missions.length, 3);
    expect(missions.first.started.isUtc, true);
    expect(missions.first.progress, 1);
    expect(missions.first.pending, greaterThan(0));
    expect(missions.first.savings, closeTo(81.2, .01));
    for (final m in missions) {
      expect(
        m.actualMl,
        closeTo(m.points.fold<double>(0, (s, d) => s + d.dosage), .001),
      );
    }
    expect(
      missions
          .expand((m) => m.points)
          .every(
            (d) =>
                d.imageUrl == null &&
                d.pesticide == null &&
                d.safeHarvestDate == null,
          ),
      true,
    );
  });
  test('fresh launch saves fixtures and a UTC cache timestamp', () async {
    final cache = MemoryCache();
    final cubit = AppCubit(cache);
    await cubit.initialize();
    expect(cubit.state.missions.length, 3);
    expect(cubit.state.cachedAt!.isUtc, true);
    expect(cache.value, isNotNull);
    expect(cubit.state.role, null);
    await cubit.close();
  });
  test(
    'offline flag and review draft survive a restart without authentication',
    () async {
      final cache = MemoryCache();
      final first = AppCubit(cache);
      await first.initialize();
      first.login(UserRole.agronomist);
      await first.review('demo-0-3', 'Approved locally');
      await first.setOffline(true);
      await first.close();
      final restarted = AppCubit(cache);
      await restarted.initialize();
      expect(restarted.state.offline, true);
      expect(restarted.state.reviews['demo-0-3'], 'Approved locally');
      expect(restarted.state.missions.length, 3);
      expect(restarted.state.role, null);
      await restarted.refresh();
      expect(restarted.state.error, contains('Offline'));
      await restarted.close();
    },
  );
  test('non-agronomists cannot change review drafts', () async {
    final c = AppCubit(MemoryCache());
    await c.initialize();
    c.login(UserRole.operator);
    await c.review('demo-0-3', 'Approved locally');
    expect(c.state.reviews, isEmpty);
    await c.close();
  });
  test('failed persistence is shown instead of claiming it saved', () async {
    final cache = MemoryCache();
    final c = AppCubit(cache);
    await c.initialize();
    cache.fail = true;
    await c.setOffline(true);
    expect(c.state.error, contains('could not be saved'));
    await c.close();
  });
  test('corrupt cache is reported and reset recovers', () async {
    final cache = MemoryCache()..value = {'rows': 'bad-json'};
    final c = AppCubit(cache);
    await c.initialize();
    expect(c.state.error, contains('could not be read'));
    await c.reset();
    expect(c.state.missions.length, 3);
    expect(c.state.error, null);
    await c.close();
  });
}
