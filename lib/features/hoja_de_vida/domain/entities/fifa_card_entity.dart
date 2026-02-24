import 'dart:typed_data';

/// Entidad de dominio: Carta FIFA personalizada del jugador.
class FifaCardEntity {
  final String nombre;
  final String posicion;
  final int overall;

  // 6 estadísticas del jugador (0-99)
  final int ritmo;
  final int tiro;
  final int pase;
  final int regate;
  final int defensa;
  final int fisico;

  // Información de contacto / club
  final String contacto;
  final String club;
  final String nacionalidad;

  /// Bytes de la foto del jugador — compatible con web y mobile.
  final Uint8List? imageBytes;

  const FifaCardEntity({
    required this.nombre,
    required this.posicion,
    required this.overall,
    required this.ritmo,
    required this.tiro,
    required this.pase,
    required this.regate,
    required this.defensa,
    required this.fisico,
    this.contacto = '',
    this.club = '',
    this.nacionalidad = '',
    this.imageBytes,
  });

  /// Valores iniciales para un jugador nuevo.
  factory FifaCardEntity.initial() => const FifaCardEntity(
        nombre: 'Tu nombre',
        posicion: 'DC',
        overall: 75,
        ritmo: 75,
        tiro: 75,
        pase: 75,
        regate: 75,
        defensa: 75,
        fisico: 75,
        contacto: '',
        club: '',
        nacionalidad: '',
      );

  FifaCardEntity copyWith({
    String? nombre,
    String? posicion,
    int? overall,
    int? ritmo,
    int? tiro,
    int? pase,
    int? regate,
    int? defensa,
    int? fisico,
    String? contacto,
    String? club,
    String? nacionalidad,
    Uint8List? imageBytes,
  }) =>
      FifaCardEntity(
        nombre: nombre ?? this.nombre,
        posicion: posicion ?? this.posicion,
        overall: overall ?? this.overall,
        ritmo: ritmo ?? this.ritmo,
        tiro: tiro ?? this.tiro,
        pase: pase ?? this.pase,
        regate: regate ?? this.regate,
        defensa: defensa ?? this.defensa,
        fisico: fisico ?? this.fisico,
        contacto: contacto ?? this.contacto,
        club: club ?? this.club,
        nacionalidad: nacionalidad ?? this.nacionalidad,
        imageBytes: imageBytes ?? this.imageBytes,
      );
}
