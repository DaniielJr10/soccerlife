const mongoose = require('mongoose');

/**
 * Modelo de Estadísticas
 * Almacena estadísticas acumuladas del jugador por temporada
 */
const estadisticaSchema = new mongoose.Schema({
  // Relación con el usuario
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true,
    unique: true, // Un documento de estadísticas por usuario
    index: true
  },
  
  // Temporada actual
  temporada: {
    type: String,
    default: () => new Date().getFullYear().toString()
  },
  
  // Estadísticas de partidos
  partidos: {
    jugados: {
      type: Number,
      default: 0,
      min: 0
    },
    ganados: {
      type: Number,
      default: 0,
      min: 0
    },
    empatados: {
      type: Number,
      default: 0,
      min: 0
    },
    perdidos: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  
  // Estadísticas ofensivas
  goles: {
    total: {
      type: Number,
      default: 0,
      min: 0
    },
    porPartido: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  
  asistencias: {
    type: Number,
    default: 0,
    min: 0
  },

  // Estadísticas de remates
  remates: {
    total: { type: Number, default: 0, min: 0 },
    alArco: { type: Number, default: 0, min: 0 }
  },

  // Estadísticas de pases
  pases: {
    completados: { type: Number, default: 0, min: 0 },
    fallidos: { type: Number, default: 0, min: 0 }
  },

  // Estadísticas de regates
  regates: {
    exitosos: { type: Number, default: 0, min: 0 },
    fallidos: { type: Number, default: 0, min: 0 }
  },

  // Estadísticas de faltas
  faltas: {
    cometidas: { type: Number, default: 0, min: 0 },
    recibidas: { type: Number, default: 0, min: 0 }
  },

  // Estadísticas disciplinarias
  tarjetas: {
    amarillas: {
      type: Number,
      default: 0,
      min: 0
    },
    rojas: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  
  // Tiempo de juego
  minutosJugados: {
    type: Number,
    default: 0,
    min: 0
  },
  
  // Valoración promedio
  valoracionPromedio: {
    type: Number,
    default: 0,
    min: 0,
    max: 10
  },
  
  // Racha actual
  rachaActual: {
    tipo: {
      type: String,
      enum: ['victorias', 'derrotas', 'empates', 'sin_perder', 'ninguna'],
      default: 'ninguna'
    },
    cantidad: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  
  // Mejor racha histórica
  mejorRacha: {
    victorias: {
      type: Number,
      default: 0,
      min: 0
    },
    sinPerder: {
      type: Number,
      default: 0,
      min: 0
    }
  },
  
  // Control
  activo: {
    type: Boolean,
    default: true
  }
  
}, {
  timestamps: true
});

// Método para calcular porcentaje de victorias
estadisticaSchema.methods.calcularPorcentajeVictorias = function() {
  if (this.partidos.jugados === 0) return 0;
  return ((this.partidos.ganados / this.partidos.jugados) * 100).toFixed(1);
};

// Método para actualizar goles por partido
estadisticaSchema.methods.actualizarGolesPorPartido = function() {
  if (this.partidos.jugados === 0) {
    this.goles.porPartido = 0;
  } else {
    this.goles.porPartido = parseFloat((this.goles.total / this.partidos.jugados).toFixed(2));
  }
};

module.exports = mongoose.model('Estadistica', estadisticaSchema);
