import '../entities/match_entity.dart';

/// Contrato del repositorio de Partidos (Domain layer).
abstract class MatchRepository {
  /// Crea un partido programado. Retorna el partido con ID asignado.
  Future<MatchEntity> createMatch(MatchEntity match);

  /// Registra el resultado y estadísticas de un partido finalizado.
  Future<MatchEntity> registerResult(MatchEntity match);

  /// Actualiza datos básicos de un partido.
  Future<MatchEntity> updateMatch(MatchEntity match);

  /// Elimina (soft-delete) un partido por ID.
  Future<void> deleteMatch(String id);

  /// Retorna todos los partidos finalizados, ordenados desc por fecha.
  Future<List<MatchEntity>> getPlayedMatches();

  /// Retorna partidos programados futuros.
  Future<List<MatchEntity>> getUpcomingMatches();

  /// Retorna un partido por su ID.
  Future<MatchEntity> getMatchById(String id);
}
