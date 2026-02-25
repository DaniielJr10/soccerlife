import '../../domain/entities/tournament_entity.dart';
import '../../domain/repositories/tournament_repository.dart';
import '../datasources/tournament_datasource.dart';

/// Implementación del repositorio de torneos usando la API remota.
class TournamentRepositoryImpl implements TournamentRepository {
  final TournamentRemoteDataSource _ds;
  const TournamentRepositoryImpl(this._ds);

  @override
  Future<List<TournamentEntity>> getAll() => _ds.fetchAll();

  @override
  Future<TournamentEntity> create(TournamentEntity torneo) => _ds.create(torneo);

  @override
  Future<TournamentEntity> update(TournamentEntity torneo) => _ds.update(torneo);

  @override
  Future<void> delete(String id) => _ds.delete(id);
}
