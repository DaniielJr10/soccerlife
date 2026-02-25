import 'package:flutter/material.dart';

/// Entidad de dominio: Torneo.
/// Representa una competición o torneo en el que participa el jugador.
class TournamentEntity {
  final String? id;
  final String nombre;
  final String descripcion;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final String estado; // 'activo' | 'finalizado'
  final String colorHex;

  const TournamentEntity({
    this.id,
    required this.nombre,
    this.descripcion = '',
    this.fechaInicio,
    this.fechaFin,
    this.estado = 'activo',
    this.colorHex = '#00D4AA',
  });

  bool get estaActivo => estado == 'activo';

  /// Color para mostrar en la UI.
  Color get color {
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return const Color(0xFF00D4AA);
    }
  }

  factory TournamentEntity.fromJson(Map<String, dynamic> j) {
    DateTime? _parseDate(dynamic v) =>
        v == null ? null : DateTime.tryParse(v.toString());

    return TournamentEntity(
      id:           j['_id']?.toString(),
      nombre:       j['nombre']?.toString() ?? '',
      descripcion:  j['descripcion']?.toString() ?? '',
      fechaInicio:  _parseDate(j['fechaInicio']),
      fechaFin:     _parseDate(j['fechaFin']),
      estado:       j['estado']?.toString() ?? 'activo',
      colorHex:     j['colorHex']?.toString() ?? '#00D4AA',
    );
  }

  Map<String, dynamic> toJson() => {
    if (id != null) '_id': id,
    'nombre':      nombre,
    'descripcion': descripcion,
    if (fechaInicio != null) 'fechaInicio': fechaInicio!.toIso8601String(),
    if (fechaFin    != null) 'fechaFin':    fechaFin!.toIso8601String(),
    'estado':   estado,
    'colorHex': colorHex,
  };

  TournamentEntity copyWith({
    String? nombre,
    String? descripcion,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    String? estado,
    String? colorHex,
  }) => TournamentEntity(
    id:          id,
    nombre:      nombre      ?? this.nombre,
    descripcion: descripcion ?? this.descripcion,
    fechaInicio: fechaInicio ?? this.fechaInicio,
    fechaFin:    fechaFin    ?? this.fechaFin,
    estado:      estado      ?? this.estado,
    colorHex:    colorHex    ?? this.colorHex,
  );
}
