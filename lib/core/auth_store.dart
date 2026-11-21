import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Real tokens belong here, never in the mission cache. Demo login writes no token.
class AuthStore {
  const AuthStore();
  static const _storage = FlutterSecureStorage();
  Future<void> saveToken(String token) =>
      _storage.write(key: 'faddan_access_token', value: token);
  Future<String?> token() => _storage.read(key: 'faddan_access_token');
  Future<void> clear() => _storage.delete(key: 'faddan_access_token');
}
