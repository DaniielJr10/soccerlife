import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

/// Caso de uso: Consultar listados de partidos.
class GetMatchesUseCase {
  final MatchRepository _repository;

  const GetMatchesUseCase(this._repository);

  Future<List<MatchEntity>> played() => _repository.getPlayedMatches();

  Future<List<MatchEntity>> upcoming() => _repository.getUpcomingMatches();

  Future<MatchEntity> byId(String id) => _repository.getMatchById(id);
}
