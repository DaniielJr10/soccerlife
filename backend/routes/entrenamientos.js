const express = require('express');
const router = express.Router();
const { verificarToken } = require('../middleware/auth');

// Controladores
const {
  crearEntrenamiento,
  obtenerEntrenamientos,
  obtenerEntrenamientosProximos,
  obtenerEntrenamientosAnteriores,
  obtenerEntrenamientoPorId
} = require('../controllers/entrenamientos/entrenamientosController');

const {
  actualizarEntrenamiento,
  completarEntrenamiento,
  eliminarEntrenamiento
} = require('../controllers/entrenamientos/entrenamientosActualizarController');

// ===== RUTAS PROTEGIDAS (requieren autenticación) =====

// Crear nuevo entrenamiento
router.post('/', verificarToken, crearEntrenamiento);

// Obtener todos los entrenamientos del usuario
router.get('/', verificarToken, obtenerEntrenamientos);

// Obtener entrenamientos próximos
router.get('/proximos', verificarToken, obtenerEntrenamientosProximos);

// Obtener entrenamientos anteriores (completados)
router.get('/anteriores', verificarToken, obtenerEntrenamientosAnteriores);

// Obtener un entrenamiento específico
router.get('/:id', verificarToken, obtenerEntrenamientoPorId);

// Actualizar entrenamiento
router.put('/:id', verificarToken, actualizarEntrenamiento);

// Marcar entrenamiento como completado
router.put('/:id/completar', verificarToken, completarEntrenamiento);

// Eliminar entrenamiento
router.delete('/:id', verificarToken, eliminarEntrenamiento);

module.exports = router;
