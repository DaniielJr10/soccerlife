import '../entities/match_entity.dart';
import '../repositories/match_repository.dart';

/// Caso de uso: actualiza datos básicos + estadísticas de un partido finalizado.
class UpdateMatchUseCase {
  final MatchRepository _repo;
  const UpdateMatchUseCase(this._repo);

  Future<MatchEntity> call(MatchEntity match) => _repo.updateFullMatch(match);
}
