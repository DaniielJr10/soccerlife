/// Entidad de dominio: Estadísticas acumuladas del jugador.
class StatisticsEntity {
  // Partidos
  final int partidosJugados;
  final int partidosGanados;
  final int partidosEmpatados;
  final int partidosPerdidos;

  // Ofensiva
  final int goles;
  final double golesPorPartido;
  final int asistencias;
  final int remates;
  final int rematesAlArco;

  // Pases
  final int pasesCompletados;
  final int pasesFallidos;

  // Regates
  final int regatesExitosos;
  final int regatesFallidos;

  // Faltas
  final int faltasCometidas;
  final int faltasRecibidas;

  // Disciplina
  final int tarjetasAmarillas;
  final int tarjetasRojas;

  // Tiempo
  final int minutosJugados;

  // Valoración
  final double valoracionPromedio;

  const StatisticsEntity({
    this.partidosJugados = 0,
    this.partidosGanados = 0,
    this.partidosEmpatados = 0,
    this.partidosPerdidos = 0,
    this.goles = 0,
    this.golesPorPartido = 0,
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
    this.valoracionPromedio = 0,
  });

  /// Porcentaje de victorias (0–100).
  double get porcentajeVictorias {
    if (partidosJugados == 0) return 0;
    return (partidosGanados / partidosJugados) * 100;
  }

  /// Minutos jugados como horas y minutos (ej: 12h 30m).
  String get minutosFormateados {
    final h = minutosJugados ~/ 60;
    final m = minutosJugados % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  double get precisionRemates {
    if (remates == 0) return 0;
    return (rematesAlArco / remates) * 100;
  }

  double get precisionPases {
    final total = pasesCompletados + pasesFallidos;
    if (total == 0) return 0;
    return (pasesCompletados / total) * 100;
  }

  double get precisionRegates {
    final total = regatesExitosos + regatesFallidos;
    if (total == 0) return 0;
    return (regatesExitosos / total) * 100;
  }

  /// Instancia vacía para estado inicial.
  static const empty = StatisticsEntity();
}
