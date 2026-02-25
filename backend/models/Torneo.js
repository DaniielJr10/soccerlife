const mongoose = require('mongoose');

/**
 * Modelo de Torneo
 * Representa un torneo o competición en la que participa el jugador.
 */
const torneoSchema = new mongoose.Schema({
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true,
    index: true
  },

  nombre: {
    type: String,
    required: true,
    trim: true,
    maxlength: 100
  },

  descripcion: {
    type: String,
    trim: true,
    maxlength: 300,
    default: ''
  },

  fechaInicio: {
    type: Date,
    default: null
  },

  fechaFin: {
    type: Date,
    default: null
  },

  estado: {
    type: String,
    enum: ['activo', 'finalizado'],
    default: 'activo'
  },

  // Color en hex para mostrar en la UI (ej: "#00D4AA")
  colorHex: {
    type: String,
    default: '#00D4AA',
    trim: true
  },

  activo: {
    type: Boolean,
    default: true
  }

}, { timestamps: true });

torneoSchema.index({ usuarioId: 1, estado: 1 });

module.exports = mongoose.model('Torneo', torneoSchema);
