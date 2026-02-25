import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'profile_picture_service.dart';

/// Estado global de la foto de perfil.
/// Permite que cualquier widget de la app (Dashboard, Perfil, etc.)
/// reaccione automáticamente cuando la foto cambia.
class ProfilePictureProvider extends ChangeNotifier {
  Uint8List? _photoBytes;
  bool _isLoading = false;

  Uint8List? get photoBytes => _photoBytes;
  bool get isLoading => _isLoading;

  /// Carga la foto desde el servidor. Se llama al iniciar la app y al refrescar.
  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();

    final result = await ProfilePictureService.obtenerFoto();

    _isLoading = false;
    if (result.success) {
      _photoBytes = result.entity?.imageBytes;
    }
    notifyListeners();
  }

  /// Actualiza la foto localmente y notifica a todos los listeners.
  /// Pasar [null] indica que la foto fue eliminada.
  void setPhoto(Uint8List? bytes) {
    _photoBytes = bytes;
    notifyListeners();
  }
}
