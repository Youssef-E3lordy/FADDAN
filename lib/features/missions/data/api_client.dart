import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/auth_store.dart';

/// Adapter reserved for the agreed /api/v1 contract. Not selected in demo mode.
/// Listing, refresh, control and rejection routes are deliberately not invented.
class FaddanApi {
  FaddanApi({required this.baseUrl, required this.client, required this.auth});
  final Uri baseUrl;
  final http.Client client;
  final AuthStore auth;
  Future<Map<String, dynamic>> summary(String missionId) async {
    final token = await auth.token();
    if (token == null) throw StateError('Sign-in required');
    final uri = baseUrl.resolve(
      '/api/v1/missions/${Uri.encodeComponent(missionId)}/summary',
    );
    final r = await client
        .get(uri, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));
    if (r.statusCode != 200) {
      throw StateError('Summary request failed (${r.statusCode})');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}
