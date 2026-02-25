import '../entities/tournament_entity.dart';
import '../repositories/tournament_repository.dart';

/// Obtener todos los torneos del usuario.
class GetTournamentsUseCase {
  final TournamentRepository _repo;
  const GetTournamentsUseCase(this._repo);
  Future<List<TournamentEntity>> call() => _repo.getAll();
}

/// Crear un nuevo torneo.
class CreateTournamentUseCase {
  final TournamentRepository _repo;
  const CreateTournamentUseCase(this._repo);
  Future<TournamentEntity> call(TournamentEntity torneo) => _repo.create(torneo);
}

/// Actualizar un torneo existente.
class UpdateTournamentUseCase {
  final TournamentRepository _repo;
  const UpdateTournamentUseCase(this._repo);
  Future<TournamentEntity> call(TournamentEntity torneo) => _repo.update(torneo);
}

/// Eliminar un torneo.
class DeleteTournamentUseCase {
  final TournamentRepository _repo;
  const DeleteTournamentUseCase(this._repo);
  Future<void> call(String id) => _repo.delete(id);
}
