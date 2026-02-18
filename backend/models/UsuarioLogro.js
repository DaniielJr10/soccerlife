const mongoose = require('mongoose');

/**
 * Modelo de relación Usuario-Logro
 * Representa los logros desbloqueados por cada usuario
 */
const usuarioLogroSchema = new mongoose.Schema({
  // Relación con el usuario
  usuarioId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Usuario',
    required: true,
    index: true
  },
  
  // Relación con el logro
  logroId: {
    type: String, // Referencia al logroId del modelo Logro
    required: true
  },
  
  // Fecha de desbloqueo
  fechaDesbloqueo: {
    type: Date,
    default: Date.now
  },
  
  // Progreso hacia el logro (para logros con barras de progreso)
  progreso: {
    actual: {
      type: Number,
      default: 0,
      min: 0
    },
    requerido: {
      type: Number,
      required: true
    }
  },
  
  // Estado
  desbloqueado: {
    type: Boolean,
    default: false
  },
  
  // Si el logro ya fue visto/notificado al usuario
  visto: {
    type: Boolean,
    default: false
  }
  
}, {
  timestamps: true
});

// Índice compuesto para evitar duplicados
usuarioLogroSchema.index({ usuarioId: 1, logroId: 1 }, { unique: true });

// Método para verificar si se desbloqueó
usuarioLogroSchema.methods.verificarDesbloqueo = function() {
  if (this.progreso.actual >= this.progreso.requerido && !this.desbloqueado) {
    this.desbloqueado = true;
    this.fechaDesbloqueo = new Date();
    return true;
  }
  return false;
};

module.exports = mongoose.model('UsuarioLogro', usuarioLogroSchema);
