const express = require('express');
const router = express.Router();
const { verificarToken, verificarTokenOpcional } = require('../middleware/auth');

const {
  obtenerLogrosDisponibles,
  obtenerLogrosUsuario,
  verificarLogros
} = require('../controllers/logrosController');

// ===== RUTAS PÚBLICAS =====

// Obtener todos los logros disponibles (sin autenticación)
router.get('/disponibles', obtenerLogrosDisponibles);

// ===== RUTAS PROTEGIDAS (requieren autenticación) =====

// Obtener logros del usuario con progreso
router.get('/mis-logros', verificarToken, obtenerLogrosUsuario);

// Verificar y desbloquear nuevos logros
router.post('/verificar', verificarToken, verificarLogros);

module.exports = router;
