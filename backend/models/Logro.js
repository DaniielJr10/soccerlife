const mongoose = require('mongoose');

/**
 * Modelo de Logros
 * Representa los logros/achievements desbloqueados por el usuario
 */
const logroSchema = new mongoose.Schema({
  // ID único del logro (no cambia, se usa para identificar el tipo)
  logroId: {
    type: String,
    required: true,
    unique: true,
    index: true
  },
  
  // Información del logro
  titulo: {
    type: String,
    required: true,
    trim: true
  },
  
  descripcion: {
    type: String,
    required: true,
    trim: true,
    maxlength: 200
  },
  
  icono: {
    type: String,
    required: true
  },
  
  color: {
    type: String,
    default: '#FFD700' // Dorado por defecto
  },
  
  // Categoría del logro
  categoria: {
    type: String,
    enum: ['partidos', 'goles', 'entrenamientos', 'racha', 'especial'],
    required: true
  },
  
  // Requisitos para desbloquear
  requisito: {
    tipo: {
      type: String,
      enum: ['partidos_jugados', 'goles', 'asistencias', 'victorias', 
             'entrenamientos', 'racha_victorias', 'valoracion', 'especial'],
      required: true
    },
    cantidad: {
      type: Number,
      required: true,
      min: 1
    }
  },
  
  // Puntos que otorga
  puntos: {
    type: Number,
    default: 10,
    min: 0
  },
  
  // Rareza
  rareza: {
    type: String,
    enum: ['Común', 'Raro', 'Épico', 'Legendario'],
    default: 'Común'
  },
  
  // Control
  activo: {
    type: Boolean,
    default: true
  }
  
}, {
  timestamps: true
});

module.exports = mongoose.model('Logro', logroSchema);
