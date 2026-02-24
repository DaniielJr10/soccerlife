import '../../domain/entities/match_entity.dart';
import '../../domain/repositories/match_repository.dart';
import '../datasources/match_remote_datasource.dart';

/// Implementación del repositorio de partidos.
/// Delega a [MatchRemoteDataSource] y traduce excepciones de red.
class MatchRepositoryImpl implements MatchRepository {
  final MatchRemoteDataSource _dataSource;

  const MatchRepositoryImpl(this._dataSource);

  @override
  Future<MatchEntity> createMatch(MatchEntity match) =>
      _dataSource.create(match);

  @override
  Future<MatchEntity> registerResult(MatchEntity match) =>
      _dataSource.registerResult(match);

  @override
  Future<MatchEntity> updateMatch(MatchEntity match) =>
      _dataSource.update(match);

  @override
  Future<void> deleteMatch(String id) => _dataSource.delete(id);

  @override
  Future<List<MatchEntity>> getPlayedMatches() => _dataSource.fetchPlayed();

  @override
  Future<List<MatchEntity>> getUpcomingMatches() => _dataSource.fetchUpcoming();

  @override
  Future<MatchEntity> getMatchById(String id) => _dataSource.fetchById(id);
}
