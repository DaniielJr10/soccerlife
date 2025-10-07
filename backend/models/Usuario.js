const mongoose = require('mongoose');

const usuarioSchema = new mongoose.Schema({
  nombre: {
    type: String,
    required: true,
    trim: true
  },
  email: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true
  },
  password: {
    type: String,
    required: true,
    minlength: 6
  },
  posicion: {
    type: String,
    enum: ['Portero', 'Defensor', 'Mediocampista', 'Delantero'],
    default: 'Mediocampista'
  },
  numeroJugador: {
    type: Number,
    min: 1,
    max: 99
  },
  fechaNacimiento: {
    type: Date
  },
  activo: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true // Agrega createdAt y updatedAt automáticamente
});

module.exports = mongoose.model('Usuario', usuarioSchema);
