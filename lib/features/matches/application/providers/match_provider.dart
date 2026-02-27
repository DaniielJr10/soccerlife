import 'package:flutter/material.dart';
import '../../domain/entities/match_entity.dart';
import '../../domain/usecases/register_match_usecase.dart';
import '../../domain/usecases/get_matches_usecase.dart';
import '../../domain/usecases/delete_match_usecase.dart';
import '../../domain/usecases/update_match_usecase.dart';
import '../../infrastructure/datasources/match_remote_datasource.dart';
import '../../infrastructure/repositories/match_repository_impl.dart';

enum MatchStatus { idle, loading, success, error }

/// Estado y lógica de la feature de Partidos.
class MatchProvider extends ChangeNotifier {
  // ── Dependencias ──────────────────────────────────────────────────────────
  final RegisterMatchUseCase _register;
  final GetMatchesUseCase _getMatches;
  final DeleteMatchUseCase _delete;
  final UpdateMatchUseCase _update;

  factory MatchProvider() {
    final repo = MatchRepositoryImpl(MatchRemoteDataSource());
    return MatchProvider._internal(
      register:   RegisterMatchUseCase(repo),
      getMatches: GetMatchesUseCase(repo),
      delete:     DeleteMatchUseCase(repo),
      update:     UpdateMatchUseCase(repo),
    );
  }

  MatchProvider._internal({
    required RegisterMatchUseCase register,
    required GetMatchesUseCase getMatches,
    required DeleteMatchUseCase delete,
    required UpdateMatchUseCase update,
  })  : _register   = register,
        _getMatches = getMatches,
        _delete     = delete,
        _update     = update;

  // ── Estado ────────────────────────────────────────────────────────────────
  List<MatchEntity> _played   = [];
  List<MatchEntity> _upcoming = [];
  MatchStatus _status         = MatchStatus.idle;
  String? _errorMessage;

  List<MatchEntity> get played   => List.unmodifiable(_played);
  List<MatchEntity> get upcoming => List.unmodifiable(_upcoming);
  MatchStatus       get status   => _status;
  String?           get errorMessage => _errorMessage;
  bool get isLoading => _status == MatchStatus.loading;

  // ── Leer ──────────────────────────────────────────────────────────────────

  Future<void> loadPlayed() async {
    _setLoading();
    try {
      _played = await _getMatches.played();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUpcoming() async {
    _setLoading();
    try {
      _upcoming = await _getMatches.upcoming();
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadAll() async {
    _setLoading();
    try {
      final results = await Future.wait([
        _getMatches.played(),
        _getMatches.upcoming(),
      ]);
      _played   = results[0];
      _upcoming = results[1];
      _setSuccess();
    } catch (e) {
      _setError(e.toString());
    }
  }

  // ── Escribir ─────────────────────────────────────────────────────────────

  Future<bool> registerPlayed(MatchEntity match) async {
    _setLoading();
    try {
      final saved = await _register.callPlayed(match);
      _played.insert(0, saved);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> scheduleMatch(MatchEntity match) async {
    _setLoading();
    try {
      final saved = await _register.callScheduled(match);
      _upcoming.add(saved);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> updateMatch(MatchEntity match) async {
    _setLoading();
    try {
      final updated = await _update.call(match);
      final idx = _played.indexWhere((m) => m.id == match.id);
      if (idx != -1) _played[idx] = updated;
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteMatch(String id) async {
    _setLoading();
    try {
      await _delete.call(id);
      _played.removeWhere((m) => m.id == id);
      _upcoming.removeWhere((m) => m.id == id);
      _setSuccess();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _setLoading() {
    _status       = MatchStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setSuccess() {
    _status = MatchStatus.success;
    notifyListeners();
  }

  void _setError(String msg) {
    _status       = MatchStatus.error;
    _errorMessage = msg.replaceFirst('Exception: ', '');
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    _status       = MatchStatus.idle;
    notifyListeners();
  }
}
