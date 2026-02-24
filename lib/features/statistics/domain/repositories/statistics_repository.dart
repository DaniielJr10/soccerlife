import '../entities/statistics_entity.dart';

/// Contrato del repositorio de Estadísticas (Domain layer).
abstract class StatisticsRepository {
  /// Retorna las estadísticas acumuladas del jugador autenticado.
  Future<StatisticsEntity> getStatistics();
}
