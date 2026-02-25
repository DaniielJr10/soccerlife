const mongoose = require('mongoose');

/**
 * Modelo de Partido
 * Representa un partido de fútbol (jugado o futuro)
 */
const partidoSchema = new mongoose.Schema({
  // Relación con el usuario
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true,
    index: true
  },
  
  // Información básica del partido
  equipoRival: {
    type: String,
    required: true,
    trim: true
  },
  
  fecha: {
    type: Date,
    required: true
  },
  
  hora: {
    type: String, // Formato: "HH:mm"
    required: true
  },
  
  lugar: {
    type: String,
    required: true,
    trim: true
  },
  
  // Tipo de partido
  tipo: {
    type: String,
    enum: ['Amistoso', 'Torneo', 'Liga', 'Copa', 'Entrenamiento'],
    default: 'Amistoso'
  },
  
  // Estado del partido
  estado: {
    type: String,
    enum: ['programado', 'en_curso', 'finalizado', 'cancelado'],
    default: 'programado'
  },
  
  // Resultado (solo si ya se jugó)
  resultado: {
    golesLocal: {
      type: Number,
      min: 0,
      default: null
    },
    golesVisitante: {
      type: Number,
      min: 0,
      default: null
    }
  },
  
  // Competición (Liga, Copa, Amistoso, etc.)
  competicion: {
    type: String,
    trim: true,
    default: ''
  },

  // Torneo asociado (opcional)
  torneoId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Torneo',
    default: null
  },

  torneoNombre: {
    type: String,
    trim: true,
    default: ''
  },

  // Estadísticas personales del jugador en este partido
  estadisticasPersonales: {
    posicion: {
      type: String,
      trim: true,
      default: ''
    },
    goles: {
      type: Number,
      min: 0,
      default: 0
    },
    asistencias: {
      type: Number,
      min: 0,
      default: 0
    },
    remates: {
      type: Number,
      min: 0,
      default: 0
    },
    rematesAlArco: {
      type: Number,
      min: 0,
      default: 0
    },
    pasesCompletados: {
      type: Number,
      min: 0,
      default: 0
    },
    pasesFallidos: {
      type: Number,
      min: 0,
      default: 0
    },
    regatesExitosos: {
      type: Number,
      min: 0,
      default: 0
    },
    regatesFallidos: {
      type: Number,
      min: 0,
      default: 0
    },
    faltasCometidas: {
      type: Number,
      min: 0,
      default: 0
    },
    faltasRecibidas: {
      type: Number,
      min: 0,
      default: 0
    },
    tarjetasAmarillas: {
      type: Number,
      min: 0,
      default: 0
    },
    tarjetasRojas: {
      type: Number,
      min: 0,
      default: 0
    },
    minutosJugados: {
      type: Number,
      min: 0,
      max: 120,
      default: 0
    },
    valoracion: {
      type: Number,
      min: 0,
      max: 10,
      default: null
    }
  },
  
  // Notas adicionales
  notas: {
    type: String,
    trim: true,
    maxlength: 500
  },
  
  // Control
  activo: {
    type: Boolean,
    default: true
  }
  
}, {
  timestamps: true // createdAt, updatedAt
});

// Índices para mejorar rendimiento en búsquedas
partidoSchema.index({ usuarioId: 1, fecha: -1 });
partidoSchema.index({ usuarioId: 1, estado: 1 });

// Método para verificar si el partido ya se jugó
partidoSchema.methods.estaJugado = function() {
  return this.estado === 'finalizado';
};

// Método para calcular resultado
partidoSchema.methods.obtenerResultado = function() {
  if (!this.estaJugado()) return null;
  
  const { golesLocal, golesVisitante } = this.resultado;
  if (golesLocal > golesVisitante) return 'victoria';
  if (golesLocal < golesVisitante) return 'derrota';
  return 'empate';
};

// Virtual para saber si es partido futuro
partidoSchema.virtual('esFuturo').get(function() {
  return new Date(this.fecha) > new Date() && this.estado === 'programado';
});

// Incluir virtuals en JSON
partidoSchema.set('toJSON', { virtuals: true });
partidoSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Partido', partidoSchema);
