import 'package:hive_flutter/hive_flutter.dart';

abstract interface class CacheStore {
  Future<void> save(Map<String, dynamic> value);
  Map<String, dynamic>? read();
  Future<void> clear();
}

class HiveCache implements CacheStore {
  HiveCache(this.box);
  final Box<dynamic> box;
  @override
  Future<void> save(Map<String, dynamic> value) =>
      box.put('demo:missions:v1', value);
  @override
  Map<String, dynamic>? read() {
    final value = box.get('demo:missions:v1');
    return value is Map ? Map<String, dynamic>.from(value) : null;
  }

  @override
  Future<void> clear() => box.clear();
}
