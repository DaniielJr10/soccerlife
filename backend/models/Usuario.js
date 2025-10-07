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
    enum: ['Arquero', 'Defensa Central', 'Lateral', 'Volante', 'Extremo', 'Delantero'],
    default: 'Volante'
  },
  numeroJugador: {
    type: Number,
    min: 1,
    max: 99
  },
  telefono: {
    type: String,
    trim: true
  },
  club: {
    type: String,
    trim: true
  },
  edad: {
    type: Number,
    min: 12,
    max: 100
  },
  estatura: {
    type: Number,
    min: 100,
    max: 250
  },
  peso: {
    type: Number,
    min: 30,
    max: 200
  },
  activo: {
    type: Boolean,
    default: true
  }
}, {
  timestamps: true // Agrega createdAt y updatedAt automáticamente
});

module.exports = mongoose.model('Usuario', usuarioSchema);
