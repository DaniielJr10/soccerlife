import '../entities/statistics_entity.dart';
import '../repositories/statistics_repository.dart';

/// Caso de uso: Obtener estadísticas acumuladas del jugador.
class GetStatisticsUseCase {
  final StatisticsRepository _repository;

  const GetStatisticsUseCase(this._repository);

  Future<StatisticsEntity> call() => _repository.getStatistics();
}
