import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/api_config.dart';
import '../../../../services/auth_service.dart';
import '../../domain/entities/match_entity.dart';

/// Fuente de datos remota para Partidos.
/// Se comunica directamente con la REST API del backend.
class MatchRemoteDataSource {
  static String get _base => '${ApiConfig.baseUrl}/partidos';

  // ── Leer ─────────────────────────────────────────────────────────────────

  Future<List<MatchEntity>> fetchPlayed() async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.get(
      Uri.parse('$_base?estado=finalizado&limit=100'),
      headers: headers,
    );
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    final list = data['partidos'] as List? ?? [];
    return list.map<MatchEntity>((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MatchEntity>> fetchUpcoming() async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.get(
      Uri.parse('$_base/futuros'),
      headers: headers,
    );
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    final list = data['partidos'] as List? ?? [];
    return list.map<MatchEntity>((e) => _fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MatchEntity> fetchById(String id) async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.get(Uri.parse('$_base/$id'), headers: headers);
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return _fromJson(data['partido'] as Map<String, dynamic>);
  }

  // ── Escribir ──────────────────────────────────────────────────────────────

  Future<MatchEntity> create(MatchEntity match) async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final body = {
      'equipoRival': match.rival,
      'fecha': match.fecha.toIso8601String(),
      'hora': match.hora,
      'lugar': match.lugar,
      'tipo': match.tipo,
      'competicion': match.competicion,
      'condicion': match.condicion,
      if (match.torneoId != null)     'torneoId':     match.torneoId,
      if (match.torneoNombre != null) 'torneoNombre': match.torneoNombre,
      if (match.notas != null && match.notas!.isNotEmpty) 'notas': match.notas,
    };
    final res = await http.post(
      Uri.parse(_base),
      headers: headers,
      body: json.encode(body),
    );
    _assertCreated(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return _fromJson(data['partido'] as Map<String, dynamic>);
  }

  Future<MatchEntity> registerResult(MatchEntity match) async {
    if (match.id == null) throw Exception('ID de partido requerido');
    final headers = await AuthService.obtenerHeadersAutenticados();
    final body = {
      'golesLocal':        match.golesLocal ?? 0,
      'golesVisitante':    match.golesVisitante ?? 0,
      'posicion':          match.posicion,
      'goles':             match.goles,
      'asistencias':       match.asistencias,
      'remates':           match.remates,
      'rematesAlArco':     match.rematesAlArco,
      'pasesCompletados':  match.pasesCompletados,
      'pasesFallidos':     match.pasesFallidos,
      'regatesExitosos':   match.regatesExitosos,
      'regatesFallidos':   match.regatesFallidos,
      'faltasCometidas':   match.faltasCometidas,
      'faltasRecibidas':   match.faltasRecibidas,
      'tarjetasAmarillas': match.tarjetasAmarillas,
      'tarjetasRojas':     match.tarjetasRojas,
      'minutosJugados':    match.minutosJugados,
      if (match.valoracion != null) 'valoracion': match.valoracion,
    };
    final res = await http.put(
      Uri.parse('${_base}/${match.id}/resultado'),
      headers: headers,
      body: json.encode(body),
    );
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return _fromJson(data['partido'] as Map<String, dynamic>);
  }

  Future<MatchEntity> update(MatchEntity match) async {
    if (match.id == null) throw Exception('ID de partido requerido');
    final headers = await AuthService.obtenerHeadersAutenticados();
    final body = {
      'equipoRival': match.rival,
      'fecha': match.fecha.toIso8601String(),
      'hora': match.hora,
      'lugar': match.lugar,
      'tipo': match.tipo,
      'competicion': match.competicion,
      if (match.notas != null) 'notas': match.notas,
    };
    final res = await http.put(
      Uri.parse('$_base/${match.id}'),
      headers: headers,
      body: json.encode(body),
    );
    _assertOk(res);
    final data = json.decode(res.body) as Map<String, dynamic>;
    return _fromJson(data['partido'] as Map<String, dynamic>);
  }

  /// Actualiza info básica + estadísticas de un partido ya finalizado.
  /// Llama a PUT /:id y luego a PUT /:id/resultado en secuencia.
  Future<MatchEntity> updateFull(MatchEntity match) async {
    if (match.id == null) throw Exception('ID de partido requerido');
    final headers = await AuthService.obtenerHeadersAutenticados();

    // 1. Datos básicos
    final bodyBasic = {
      'equipoRival': match.rival,
      'fecha':       match.fecha.toIso8601String(),
      'hora':        match.hora,
      'lugar':       match.lugar,
      'tipo':        match.tipo,
      'competicion': match.competicion,
      'condicion':   match.condicion,
      if (match.torneoId != null)     'torneoId':     match.torneoId,
      if (match.torneoNombre != null) 'torneoNombre': match.torneoNombre,
      if (match.notas != null)        'notas':        match.notas,
    };
    final r1 = await http.put(
      Uri.parse('$_base/${match.id}'),
      headers: headers,
      body: json.encode(bodyBasic),
    );
    _assertOk(r1);

    // 2. Resultado + estadísticas
    final bodyResult = {
      'golesLocal':        match.golesLocal ?? 0,
      'golesVisitante':    match.golesVisitante ?? 0,
      'posicion':          match.posicion,
      'goles':             match.goles,
      'asistencias':       match.asistencias,
      'remates':           match.remates,
      'rematesAlArco':     match.rematesAlArco,
      'pasesCompletados':  match.pasesCompletados,
      'pasesFallidos':     match.pasesFallidos,
      'regatesExitosos':   match.regatesExitosos,
      'regatesFallidos':   match.regatesFallidos,
      'faltasCometidas':   match.faltasCometidas,
      'faltasRecibidas':   match.faltasRecibidas,
      'tarjetasAmarillas': match.tarjetasAmarillas,
      'tarjetasRojas':     match.tarjetasRojas,
      'minutosJugados':    match.minutosJugados,
      if (match.valoracion != null) 'valoracion': match.valoracion,
    };
    final r2 = await http.put(
      Uri.parse('$_base/${match.id}/resultado'),
      headers: headers,
      body: json.encode(bodyResult),
    );
    _assertOk(r2);
    final data = json.decode(r2.body) as Map<String, dynamic>;
    return _fromJson(data['partido'] as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.delete(Uri.parse('$_base/$id'), headers: headers);
    _assertOk(res);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = _errorMsg(res);
      throw Exception(msg);
    }
  }

  void _assertCreated(http.Response res) {
    if (res.statusCode != 201) {
      final msg = _errorMsg(res);
      throw Exception(msg);
    }
  }

  String _errorMsg(http.Response res) {
    try {
      return (json.decode(res.body) as Map)['message']?.toString() ??
          'Error ${res.statusCode}';
    } catch (_) {
      return 'Error ${res.statusCode}';
    }
  }

  MatchEntity _fromJson(Map<String, dynamic> p) {
    final stats = (p['estadisticasPersonales'] as Map<String, dynamic>?) ?? {};
    final res   = (p['resultado'] as Map<String, dynamic>?) ?? {};

    return MatchEntity(
      id:               p['_id']?.toString(),
      rival:            p['equipoRival']?.toString() ?? '',
      fecha:            DateTime.tryParse(p['fecha']?.toString() ?? '') ?? DateTime.now(),
      hora:             p['hora']?.toString() ?? '00:00',
      lugar:            p['lugar']?.toString() ?? '',
      tipo:             p['tipo']?.toString() ?? 'Amistoso',
      competicion:      p['competicion']?.toString() ?? '',
      condicion:        p['condicion']?.toString() ?? 'local',
      estado:           p['estado']?.toString() ?? 'programado',
      notas:            p['notas']?.toString(),
      torneoId:         p['torneoId']?.toString(),
      torneoNombre:     p['torneoNombre']?.toString(),
      golesLocal:       _int(res['golesLocal']),
      golesVisitante:   _int(res['golesVisitante']),
      posicion:         stats['posicion']?.toString() ?? '',
      goles:            _int(stats['goles']),
      asistencias:      _int(stats['asistencias']),
      remates:          _int(stats['remates']),
      rematesAlArco:    _int(stats['rematesAlArco']),
      pasesCompletados: _int(stats['pasesCompletados']),
      pasesFallidos:    _int(stats['pasesFallidos']),
      regatesExitosos:  _int(stats['regatesExitosos']),
      regatesFallidos:  _int(stats['regatesFallidos']),
      faltasCometidas:  _int(stats['faltasCometidas']),
      faltasRecibidas:  _int(stats['faltasRecibidas']),
      tarjetasAmarillas:_int(stats['tarjetasAmarillas']),
      tarjetasRojas:    _int(stats['tarjetasRojas']),
      minutosJugados:   _int(stats['minutosJugados']),
      valoracion:       _double(stats['valoracion']),
    );
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  double? _double(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    return double.tryParse(v.toString());
  }
}
