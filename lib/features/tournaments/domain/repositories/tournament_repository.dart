import '../entities/tournament_entity.dart';

/// Contrato abstracto del repositorio de torneos.
abstract class TournamentRepository {
  Future<List<TournamentEntity>> getAll();
  Future<TournamentEntity>       create(TournamentEntity torneo);
  Future<TournamentEntity>       update(TournamentEntity torneo);
  Future<void>                   delete(String id);
}
