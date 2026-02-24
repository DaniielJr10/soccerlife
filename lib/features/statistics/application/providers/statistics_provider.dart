import 'package:flutter/material.dart';
import '../../domain/entities/statistics_entity.dart';
import '../../domain/usecases/get_statistics_usecase.dart';
import '../../infrastructure/datasources/statistics_remote_datasource.dart';
import '../../infrastructure/repositories/statistics_repository_impl.dart';

enum StatsStatus { idle, loading, success, error }

/// Estado y lógica de la feature de Estadísticas.
class StatisticsProvider extends ChangeNotifier {
  late final GetStatisticsUseCase _useCase;

  StatisticsProvider() {
    final ds   = StatisticsRemoteDataSource();
    final repo = StatisticsRepositoryImpl(ds);
    _useCase   = GetStatisticsUseCase(repo);
  }

  StatisticsEntity _stats  = StatisticsEntity.empty;
  StatsStatus _status      = StatsStatus.idle;
  String? _errorMessage;

  StatisticsEntity get stats        => _stats;
  StatsStatus      get status       => _status;
  String?          get errorMessage => _errorMessage;
  bool get isLoading                => _status == StatsStatus.loading;

  Future<void> load() async {
    _status       = StatsStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      _stats  = await _useCase.call();
      _status = StatsStatus.success;
    } catch (e) {
      _status       = StatsStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status       = StatsStatus.idle;
    notifyListeners();
  }
}
