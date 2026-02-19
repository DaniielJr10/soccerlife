/// Modelo que representa los datos del usuario autenticado.
/// Se usa en toda la app para mostrar información del perfil.
class UsuarioModel {
  final String nombre;
  final String email;
  final String posicion;
  final String club;
  final int edad;

  const UsuarioModel({
    required this.nombre,
    required this.email,
    required this.posicion,
    required this.club,
    required this.edad,
  });

  /// Crea un usuario vacío (valores por defecto para nuevos usuarios).
  factory UsuarioModel.vacio() => const UsuarioModel(
        nombre: '',
        email: '',
        posicion: '',
        club: '',
        edad: 0,
      );

  /// Crea el modelo desde un mapa (respuesta del backend).
  factory UsuarioModel.fromMap(Map<String, dynamic> map) => UsuarioModel(
        nombre: map['nombre']?.toString() ?? '',
        email: map['email']?.toString() ?? '',
        posicion: map['posicion']?.toString() ?? '',
        club: map['club']?.toString() ?? '',
        edad: map['edad'] is int
            ? map['edad'] as int
            : int.tryParse(map['edad']?.toString() ?? '') ?? 0,
      );

  /// Iniciales del nombre para el avatar.
  String get iniciales {
    final partes = nombre.trim().split(' ');
    if (partes.isEmpty || nombre.isEmpty) return '?';
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
  }

  bool get estaVacio => nombre.isEmpty;
}
