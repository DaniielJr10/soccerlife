import '../repositories/match_repository.dart';

/// Caso de uso: Eliminar un partido por ID.
class DeleteMatchUseCase {
  final MatchRepository _repository;

  const DeleteMatchUseCase(this._repository);

  Future<void> call(String matchId) => _repository.deleteMatch(matchId);
}
