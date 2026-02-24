const express = require('express');
const router = express.Router();
const {
  obtenerUsuarios,
  obtenerUsuarioPorId,
  crearUsuario,
  actualizarUsuario,
  eliminarUsuario,
  obtenerMiPerfil,
  actualizarMiPerfil,
  // Carta FIFA
  obtenerCartaFifa,
  guardarCartaFifa,
  eliminarCartaFifa,
  // CV PDF
  obtenerInfoCv,
  guardarCv,
  eliminarCv,
  // Foto de perfil
  obtenerFotoPerfil,
  guardarFotoPerfil,
  eliminarFotoPerfil,
} = require('../controllers/usuarioController');
const { loginUsuario } = require('../controllers/loginController');
const { verificarToken } = require('../middleware/auth');
const {
  solicitarRecuperacionEmail,
  verificarCodigoRecuperacion,
  cambiarPasswordRecuperacion
} = require('../controllers/recuperarController');

// ── Perfil ────────────────────────────────────────────────────────────────────
// GET /api/usuarios/mi-perfil
router.get('/mi-perfil', verificarToken, obtenerMiPerfil);
// PUT /api/usuarios/mi-perfil
router.put('/mi-perfil', verificarToken, actualizarMiPerfil);

// ── Carta FIFA ────────────────────────────────────────────────────────────────
// GET  /api/usuarios/carta-fifa
router.get('/carta-fifa', verificarToken, obtenerCartaFifa);
// PUT  /api/usuarios/carta-fifa  (crea o actualiza)
router.put('/carta-fifa', verificarToken, guardarCartaFifa);
// DELETE /api/usuarios/carta-fifa
router.delete('/carta-fifa', verificarToken, eliminarCartaFifa);

// ── CV en PDF ─────────────────────────────────────────────────────────────────
// GET  /api/usuarios/cv  (devuelve info: existe + nombre, NO los bytes)
router.get('/cv', verificarToken, obtenerInfoCv);
// POST /api/usuarios/cv  (guarda/reemplaza el PDF)
router.post('/cv', verificarToken, guardarCv);
// DELETE /api/usuarios/cv
router.delete('/cv', verificarToken, eliminarCv);

// ── Auth ──────────────────────────────────────────────────────────────────────
// POST /api/usuarios/login
router.post('/login', loginUsuario);
// Recuperación de contraseña
router.post('/recuperar-password/email', solicitarRecuperacionEmail);
router.post('/verificar-codigo-recuperacion', verificarCodigoRecuperacion);
router.post('/cambiar-password-recuperacion', cambiarPasswordRecuperacion);

// ── Foto de perfil ──────────────────────────────────────────────────────────
// GET  /api/usuarios/foto-perfil
router.get('/foto-perfil', verificarToken, obtenerFotoPerfil);
// PUT  /api/usuarios/foto-perfil
router.put('/foto-perfil', verificarToken, guardarFotoPerfil);
// DELETE /api/usuarios/foto-perfil
router.delete('/foto-perfil', verificarToken, eliminarFotoPerfil);

// ── CRUD general ──────────────────────────────────────────────────────────────
router.get('/', obtenerUsuarios);
router.get('/:id', obtenerUsuarioPorId);
router.post('/', crearUsuario);
router.put('/:id', actualizarUsuario);
router.delete('/:id', eliminarUsuario);

module.exports = router;

