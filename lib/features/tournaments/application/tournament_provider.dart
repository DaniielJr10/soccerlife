import 'package:flutter/material.dart';
import '../domain/entities/tournament_entity.dart';
import '../domain/usecases/tournament_usecases.dart';
import '../infrastructure/datasources/tournament_datasource.dart';
import '../infrastructure/repositories/tournament_repository_impl.dart';

enum TournamentStatus { idle, loading, success, error }

/// Estado y lógica global de la feature Torneos.
/// Compartido entre TournamentsPage y MatchFormPage.
class TournamentProvider extends ChangeNotifier {
  late final GetTournamentsUseCase    _getAll;
  late final CreateTournamentUseCase  _create;
  late final UpdateTournamentUseCase  _update;
  late final DeleteTournamentUseCase  _delete;

  TournamentProvider() {
    final repo = TournamentRepositoryImpl(TournamentRemoteDataSource());
    _getAll  = GetTournamentsUseCase(repo);
    _create  = CreateTournamentUseCase(repo);
    _update  = UpdateTournamentUseCase(repo);
    _delete  = DeleteTournamentUseCase(repo);
  }

  List<TournamentEntity> _items  = [];
  TournamentStatus _status       = TournamentStatus.idle;
  String? _errorMessage;

  List<TournamentEntity> get items        => List.unmodifiable(_items);
  TournamentStatus       get status       => _status;
  String?                get errorMessage => _errorMessage;
  bool                   get isLoading    => _status == TournamentStatus.loading;

  // ── Leer ──────────────────────────────────────────────────────────────────

  Future<void> load() async {
    _set(TournamentStatus.loading);
    try {
      _items = await _getAll();
      _set(TournamentStatus.success);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _set(TournamentStatus.error);
    }
  }

  // ── Crear ─────────────────────────────────────────────────────────────────

  Future<bool> create(TournamentEntity torneo) async {
    _set(TournamentStatus.loading);
    try {
      final saved = await _create(torneo);
      _items = [saved, ..._items];
      _set(TournamentStatus.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _set(TournamentStatus.error);
      return false;
    }
  }

  // ── Actualizar ────────────────────────────────────────────────────────────

  Future<bool> update(TournamentEntity torneo) async {
    _set(TournamentStatus.loading);
    try {
      final updated = await _update(torneo);
      _items = _items.map((t) => t.id == updated.id ? updated : t).toList();
      _set(TournamentStatus.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _set(TournamentStatus.error);
      return false;
    }
  }

  // ── Eliminar ──────────────────────────────────────────────────────────────

  Future<bool> delete(String id) async {
    _set(TournamentStatus.loading);
    try {
      await _delete(id);
      _items = _items.where((t) => t.id != id).toList();
      _set(TournamentStatus.success);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _set(TournamentStatus.error);
      return false;
    }
  }

  void _set(TournamentStatus s) {
    _status = s;
    notifyListeners();
  }
}
