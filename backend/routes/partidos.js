const express = require('express');
const router = express.Router();
const { verificarToken } = require('../middleware/auth');

// Controladores
const {
  crearPartido,
  obtenerPartidos,
  obtenerPartidosFuturos,
  obtenerPartidosJugados,
  obtenerPartidoPorId
} = require('../controllers/partidos/partidosController');

const {
  actualizarPartido,
  registrarResultado,
  eliminarPartido
} = require('../controllers/partidos/partidosActualizarController');

// ===== RUTAS PROTEGIDAS (requieren autenticación) =====

// Crear nuevo partido
router.post('/', verificarToken, crearPartido);

// Obtener todos los partidos del usuario
router.get('/', verificarToken, obtenerPartidos);

// Obtener partidos futuros (programados)
router.get('/futuros', verificarToken, obtenerPartidosFuturos);

// Obtener partidos jugados (finalizados)
router.get('/jugados', verificarToken, obtenerPartidosJugados);

// Obtener un partido específico
router.get('/:id', verificarToken, obtenerPartidoPorId);

// Actualizar información de un partido
router.put('/:id', verificarToken, actualizarPartido);

// Registrar resultado de un partido
router.put('/:id/resultado', verificarToken, registrarResultado);

// Eliminar partido
router.delete('/:id', verificarToken, eliminarPartido);

module.exports = router;
