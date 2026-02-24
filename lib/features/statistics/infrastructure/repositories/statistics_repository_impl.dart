import '../../domain/entities/statistics_entity.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';

/// Implementación del repositorio de estadísticas.
class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource _dataSource;

  const StatisticsRepositoryImpl(this._dataSource);

  @override
  Future<StatisticsEntity> getStatistics() => _dataSource.fetchStatistics();
}
