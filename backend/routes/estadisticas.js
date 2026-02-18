const express = require('express');
const router = express.Router();
const { verificarToken } = require('../middleware/auth');

const {
  obtenerEstadisticas,
  actualizarEstadisticas,
  resetearEstadisticas
} = require('../controllers/estadisticasController');

// ===== RUTAS PROTEGIDAS (requieren autenticación) =====

// Obtener estadísticas del usuario autenticado
router.get('/', verificarToken, obtenerEstadisticas);

// Actualizar estadísticas manualmente
router.put('/', verificarToken, actualizarEstadisticas);

// Resetear estadísticas (nueva temporada)
router.post('/resetear', verificarToken, resetearEstadisticas);

module.exports = router;
