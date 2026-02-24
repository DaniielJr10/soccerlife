const mongoose = require('mongoose');

// Sub-esquema para la Carta FIFA del jugador
const cartaFifaSchema = new mongoose.Schema({
  nombre:      { type: String, trim: true },
  posicion:    { type: String, trim: true },
  overall:     { type: Number, min: 0, max: 99, default: 75 },
  ritmo:       { type: Number, min: 0, max: 99, default: 75 },
  tiro:        { type: Number, min: 0, max: 99, default: 75 },
  pase:        { type: Number, min: 0, max: 99, default: 75 },
  regate:      { type: Number, min: 0, max: 99, default: 75 },
  defensa:     { type: Number, min: 0, max: 99, default: 75 },
  fisico:      { type: Number, min: 0, max: 99, default: 75 },
  contacto:    { type: String, trim: true },
  club:        { type: String, trim: true },
  nacionalidad:{ type: String, trim: true },
  imagenBase64:{ type: String },        // foto del jugador en base64
}, { _id: false });

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
  },
  // ── CV Deportivo ──────────────────────────────────────────────────────────
  cartaFifa: { type: cartaFifaSchema, default: null },
  cvNombre:  { type: String, trim: true },     // nombre del archivo PDF
  cvBase64:  { type: String },                 // PDF codificado en base64
  // ── Foto de perfil ───────────────────────────────────────────────────
  fotoPerfil: { type: String },                // imagen en base64 (JPEG/PNG)
}, {
  timestamps: true // Agrega createdAt y updatedAt automáticamente
});

module.exports = mongoose.model('Usuario', usuarioSchema);
