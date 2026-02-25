import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/api_config.dart';
import '../../../../services/auth_service.dart';
import '../../domain/entities/tournament_entity.dart';

/// Fuente de datos remota para Torneos.
class TournamentRemoteDataSource {
  static String get _base => '${ApiConfig.baseUrl}/torneos';

  Future<List<TournamentEntity>> fetchAll() async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http
        .get(Uri.parse(_base), headers: headers)
        .timeout(const Duration(seconds: 10));
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    final list = data['torneos'] as List? ?? [];
    return list.map((e) => TournamentEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TournamentEntity> create(TournamentEntity t) async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.post(
      Uri.parse(_base),
      headers: headers,
      body: json.encode(t.toJson()),
    );
    _assertStatus(res, 201);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return TournamentEntity.fromJson(data['torneo'] as Map<String, dynamic>);
  }

  Future<TournamentEntity> update(TournamentEntity t) async {
    if (t.id == null) throw Exception('ID requerido');
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.put(
      Uri.parse('$_base/${t.id}'),
      headers: headers,
      body: json.encode(t.toJson()),
    );
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return TournamentEntity.fromJson(data['torneo'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.delete(Uri.parse('$_base/$id'), headers: headers);
    _assertOk(res);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response res) => _assertStatus(res, 200);

  void _assertStatus(http.Response res, int expected) {
    if (res.statusCode != expected && !(expected == 200 && res.statusCode < 300)) {
      String msg;
      try { msg = (json.decode(res.body) as Map)['message']?.toString() ?? 'Error ${res.statusCode}'; }
      catch (_) { msg = 'Error ${res.statusCode}'; }
      throw Exception(msg);
    }
  }
}
