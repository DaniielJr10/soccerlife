import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

/// Caso de uso: Registrar un partido completo (creación + resultado en un paso).
/// El formulario de la app envía todos los datos juntos.
class RegisterMatchUseCase {
  final MatchRepository _repository;

  const RegisterMatchUseCase(this._repository);

  /// Para un partido ya jugado: crea el partido y guarda el resultado.
  Future<MatchEntity> callPlayed(MatchEntity match) async {
    final created = await _repository.createMatch(match);
    // Usar los datos originales del formulario (con goles y estadísticas)
    // + el ID asignado por el servidor tras crear el partido.
    return _repository.registerResult(match.copyWith(id: created.id));
  }

  /// Para un partido programado (futuro): solo crea.
  Future<MatchEntity> callScheduled(MatchEntity match) {
    return _repository.createMatch(match);
  }
}

extension _MatchCopy on MatchEntity {
  MatchEntity copyWith({String? id}) => MatchEntity(
        id: id ?? this.id,
        rival: rival,
        fecha: fecha,
        hora: hora,
        lugar: lugar,
        tipo: tipo,
        competicion: competicion,
        estado: estado,
        notas: notas,
        golesLocal: golesLocal,
        golesVisitante: golesVisitante,
        posicion: posicion,
        goles: goles,
        asistencias: asistencias,
        remates: remates,
        rematesAlArco: rematesAlArco,
        pasesCompletados: pasesCompletados,
        pasesFallidos: pasesFallidos,
        regatesExitosos: regatesExitosos,
        regatesFallidos: regatesFallidos,
        faltasCometidas: faltasCometidas,
        faltasRecibidas: faltasRecibidas,
        tarjetasAmarillas: tarjetasAmarillas,
        tarjetasRojas: tarjetasRojas,
        minutosJugados: minutosJugados,
        valoracion: valoracion,
      );
}
