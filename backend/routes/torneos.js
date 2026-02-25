const express = require('express');
const router  = express.Router();
const { verificarToken } = require('../middleware/auth');
const {
  crearTorneo,
  obtenerTorneos,
  obtenerTorneoPorId,
  actualizarTorneo,
  eliminarTorneo,
} = require('../controllers/torneoController');

// Todas las rutas requieren autenticación
router.post('/',        verificarToken, crearTorneo);
router.get('/',         verificarToken, obtenerTorneos);
router.get('/:id',      verificarToken, obtenerTorneoPorId);
router.put('/:id',      verificarToken, actualizarTorneo);
router.delete('/:id',   verificarToken, eliminarTorneo);

module.exports = router;
