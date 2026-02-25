/// Entidad de dominio: Partido.
/// Contiene información del encuentro y estadísticas personales del jugador.
class MatchEntity {
  final String? id;
  final String rival;
  final DateTime fecha;
  final String hora;
  final String lugar;
  final String tipo;           // Liga / Copa / Amistoso / Torneo
  final String competicion;
  final String estado;         // programado / finalizado / cancelado
  final String? notas;

  // Torneo asociado (opcional)
  final String? torneoId;
  final String? torneoNombre;

  // Resultado del partido
  final int? golesLocal;
  final int? golesVisitante;

  // Estadísticas personales
  final String posicion;
  final int goles;
  final int asistencias;
  final int remates;
  final int rematesAlArco;
  final int pasesCompletados;
  final int pasesFallidos;
  final int regatesExitosos;
  final int regatesFallidos;
  final int faltasCometidas;
  final int faltasRecibidas;
  final int tarjetasAmarillas;
  final int tarjetasRojas;
  final int minutosJugados;
  final double? valoracion;

  const MatchEntity({
    this.id,
    required this.rival,
    required this.fecha,
    required this.hora,
    required this.lugar,
    this.tipo = 'Amistoso',
    this.competicion = '',
    this.estado = 'programado',
    this.notas,
    this.torneoId,
    this.torneoNombre,
    this.golesLocal,
    this.golesVisitante,
    this.posicion = '',
    this.goles = 0,
    this.asistencias = 0,
    this.remates = 0,
    this.rematesAlArco = 0,
    this.pasesCompletados = 0,
    this.pasesFallidos = 0,
    this.regatesExitosos = 0,
    this.regatesFallidos = 0,
    this.faltasCometidas = 0,
    this.faltasRecibidas = 0,
    this.tarjetasAmarillas = 0,
    this.tarjetasRojas = 0,
    this.minutosJugados = 0,
    this.valoracion,
  });

  bool get esFinalizado => estado == 'finalizado';
  bool get esProgramado => estado == 'programado';

  /// Resultado textual: 'V', 'E', 'D' o null si no está finalizado.
  String? get resultado {
    if (!esFinalizado || golesLocal == null || golesVisitante == null) return null;
    if (golesLocal! > golesVisitante!) return 'V';
    if (golesLocal! < golesVisitante!) return 'D';
    return 'E';
  }

  /// Precisión de remates: porcentaje de remates al arco.
  double get precisionRemates {
    if (remates == 0) return 0;
    return (rematesAlArco / remates) * 100;
  }

  /// Precisión de pases: porcentaje de pases completados.
  double get precisionPases {
    final total = pasesCompletados + pasesFallidos;
    if (total == 0) return 0;
    return (pasesCompletados / total) * 100;
  }

  /// Precisión de regates: porcentaje de regates exitosos.
  double get precisionRegates {
    final total = regatesExitosos + regatesFallidos;
    if (total == 0) return 0;
    return (regatesExitosos / total) * 100;
  }
}
