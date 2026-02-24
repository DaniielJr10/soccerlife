import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../services/api_config.dart';
import '../../../../services/auth_service.dart';
import '../../domain/entities/statistics_entity.dart';

/// Fuente de datos remota para Estadísticas acumuladas.
class StatisticsRemoteDataSource {
  static String get _base => '${ApiConfig.baseUrl}/estadisticas';

  Future<StatisticsEntity> fetchStatistics() async {
    final headers = await AuthService.obtenerHeadersAutenticados();
    final res = await http.get(Uri.parse(_base), headers: headers);

    if (res.statusCode != 200) {
      throw Exception('Error al obtener estadísticas (${res.statusCode})');
    }

    final data  = json.decode(res.body) as Map<String, dynamic>;
    final s     = (data['estadisticas'] as Map<String, dynamic>?) ?? {};

    final partidos  = (s['partidos']  as Map<String, dynamic>?) ?? {};
    final goles     = (s['goles']     as Map<String, dynamic>?) ?? {};
    final remates   = (s['remates']   as Map<String, dynamic>?) ?? {};
    final pases     = (s['pases']     as Map<String, dynamic>?) ?? {};
    final regates   = (s['regates']   as Map<String, dynamic>?) ?? {};
    final faltas    = (s['faltas']    as Map<String, dynamic>?) ?? {};
    final tarjetas  = (s['tarjetas']  as Map<String, dynamic>?) ?? {};

    return StatisticsEntity(
      partidosJugados:   _int(partidos['jugados']),
      partidosGanados:   _int(partidos['ganados']),
      partidosEmpatados: _int(partidos['empatados']),
      partidosPerdidos:  _int(partidos['perdidos']),
      goles:             _int(goles['total']),
      golesPorPartido:   _double(goles['porPartido']),
      asistencias:       _int(s['asistencias']),
      remates:           _int(remates['total']),
      rematesAlArco:     _int(remates['alArco']),
      pasesCompletados:  _int(pases['completados']),
      pasesFallidos:     _int(pases['fallidos']),
      regatesExitosos:   _int(regates['exitosos']),
      regatesFallidos:   _int(regates['fallidos']),
      faltasCometidas:   _int(faltas['cometidas']),
      faltasRecibidas:   _int(faltas['recibidas']),
      tarjetasAmarillas: _int(tarjetas['amarillas']),
      tarjetasRojas:     _int(tarjetas['rojas']),
      minutosJugados:    _int(s['minutosJugados']),
      valoracionPromedio:_double(s['valoracionPromedio']),
    );
  }

  int _int(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  double _double(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    return double.tryParse(v.toString()) ?? 0.0;
  }
}
