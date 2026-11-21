import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/cache.dart';
import '../domain/mission.dart';
import '../data/mission_dto.dart';
import '../data/demo_repository.dart';

class AppState {
  const AppState({
    this.role,
    this.missions = const [],
    this.offline = false,
    this.loading = false,
    this.cachedAt,
    this.error,
    this.reviews = const {},
  });
  final UserRole? role;
  final List<Mission> missions;
  final bool offline, loading;
  final DateTime? cachedAt;
  final String? error;
  final Map<String, String> reviews;
  AppState copy({
    UserRole? role,
    List<Mission>? missions,
    bool? offline,
    bool? loading,
    DateTime? cachedAt,
    String? error,
    Map<String, String>? reviews,
  }) => AppState(
    role: role ?? this.role,
    missions: missions ?? this.missions,
    offline: offline ?? this.offline,
    loading: loading ?? this.loading,
    cachedAt: cachedAt ?? this.cachedAt,
    error: error,
    reviews: reviews ?? this.reviews,
  );
}

class AppCubit extends Cubit<AppState> {
  AppCubit(this.cache, {MissionRepository? repository})
    : repository = repository ?? DemoMissionRepository(),
      super(const AppState());
  final MissionRepository repository;
  final CacheStore cache;
  Future<void> initialize() async {
    try {
      final c = cache.read();
      if (c != null) {
        final rows = jsonDecode(c['rows'] as String) as List;
        emit(
          AppState(
            missions: rows
                .map(
                  (j) => MissionDto.parse(Map<String, dynamic>.from(j as Map)),
                )
                .toList(),
            offline: c['offline'] == true,
            cachedAt: DateTime.tryParse(c['cached_at'] as String? ?? ''),
            reviews: Map<String, String>.from(c['reviews'] as Map? ?? {}),
          ),
        );
      }
      if (state.missions.isEmpty) await refresh();
    } catch (_) {
      emit(
        state.copy(
          error: 'Local cache could not be read. You can reload demo data.',
        ),
      );
    }
  }

  void login(UserRole role) => emit(state.copy(role: role));
  void logout() => emit(
    AppState(
      missions: state.missions,
      offline: state.offline,
      cachedAt: state.cachedAt,
      reviews: state.reviews,
    ),
  );
  Future<void> refresh() async {
    if (state.offline) {
      emit(
        state.copy(
          error: 'Offline simulation is on. Showing the last saved demo data.',
        ),
      );
      return;
    }
    emit(state.copy(loading: true));
    try {
      final missions = await repository.load();
      final text = jsonEncode(missions.map(MissionDto.encode).toList());
      final at = DateTime.now().toUtc();
      await cache.save({
        'rows': text,
        'cached_at': at.toIso8601String(),
        'offline': false,
        'reviews': state.reviews,
      });
      emit(state.copy(missions: missions, cachedAt: at, loading: false));
    } catch (_) {
      emit(
        state.copy(
          loading: false,
          error: 'Demo data could not be saved. Existing data is retained.',
        ),
      );
    }
  }

  Future<void> setOffline(bool value) async {
    emit(state.copy(offline: value));
    await _persistMeta();
  }

  Future<void> review(String id, String result) async {
    if (state.role != UserRole.agronomist) return;
    emit(state.copy(reviews: {...state.reviews, id: result}));
    await _persistMeta();
  }

  Future<void> _persistMeta() async {
    try {
      final c = cache.read();
      if (c != null) {
        await cache.save({
          ...c,
          'offline': state.offline,
          'reviews': state.reviews,
        });
      }
    } catch (_) {
      emit(state.copy(error: 'Your latest local changes could not be saved.'));
    }
  }

  Future<void> reset() async {
    await cache.clear();
    emit(AppState(role: state.role));
    await refresh();
  }
}
