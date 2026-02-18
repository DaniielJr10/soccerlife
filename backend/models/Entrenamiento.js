const mongoose = require('mongoose');

/**
 * Modelo de Entrenamiento
 * Representa una sesión de entrenamiento (pasada o futura)
 */
const entrenamientoSchema = new mongoose.Schema({
  // Relación con el usuario
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true,
    index: true
  },
  
  // Información básica
  fecha: {
    type: Date,
    required: true
  },
  
  duracion: {
    type: Number, // Duración en minutos
    required: true,
    min: 15,
    max: 300
  },
  
  tipo: {
    type: String,
    enum: ['Técnico', 'Físico', 'Táctico', 'Estratégico', 'Recuperación', 'Completo'],
    required: true
  },
  
  ubicacion: {
    type: String,
    required: true,
    trim: true
  },
  
  // Objetivos y enfoque del entrenamiento
  objetivos: {
    type: String,
    required: true,
    trim: true,
    maxlength: 300
  },
  
  // Estado
  estado: {
    type: String,
    enum: ['programado', 'en_curso', 'completado', 'cancelado'],
    default: 'programado'
  },
  
  // Intensidad del entrenamiento (solo después de completado)
  intensidad: {
    type: String,
    enum: ['Baja', 'Media', 'Alta', 'Muy Alta'],
    default: null
  },
  
  // Valoración personal (1-10)
  valoracion: {
    type: Number,
    min: 1,
    max: 10,
    default: null
  },
  
  // Habilidades trabajadas
  habilidadesTrabajadas: [{
    type: String,
    enum: [
      'Pase', 'Regate', 'Remate', 'Control', 'Velocidad',
      'Resistencia', 'Fuerza', 'Flexibilidad', 'Técnica',
      'Visión de juego', 'Defensa', 'Ataque', 'Táctica'
    ]
  }],
  
  // Notas adicionales
  notas: {
    type: String,
    trim: true,
    maxlength: 500
  },
  
  // Lesiones o molestias registradas
  lesiones: {
    type: String,
    trim: true,
    maxlength: 300
  },
  
  // Control
  activo: {
    type: Boolean,
    default: true
  }
  
}, {
  timestamps: true
});

// Índices
entrenamientoSchema.index({ usuarioId: 1, fecha: -1 });
entrenamientoSchema.index({ usuarioId: 1, estado: 1 });

// Método para verificar si el entrenamiento ya se realizó
entrenamientoSchema.methods.estaCompletado = function() {
  return this.estado === 'completado';
};

// Virtual para saber si es entrenamiento futuro
entrenamientoSchema.virtual('esFuturo').get(function() {
  return new Date(this.fecha) > new Date() && this.estado === 'programado';
});

// Incluir virtuals en JSON
entrenamientoSchema.set('toJSON', { virtuals: true });
entrenamientoSchema.set('toObject', { virtuals: true });

module.exports = mongoose.model('Entrenamiento', entrenamientoSchema);
