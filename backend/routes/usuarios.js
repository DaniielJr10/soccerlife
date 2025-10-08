const express = require('express');
const router = express.Router();
const {
  obtenerUsuarios,
  obtenerUsuarioPorId,
  crearUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../controllers/usuarioController');
const { loginUsuario } = require('../controllers/loginController');
const {
  solicitarRecuperacionEmail,
  solicitarRecuperacionTelefono,
  verificarCodigoRecuperacion,
  cambiarPasswordRecuperacion
} = require('../controllers/recuperarController');

// GET /api/usuarios - Obtener todos los usuarios
router.get('/', obtenerUsuarios);

// GET /api/usuarios/:id - Obtener un usuario por ID
router.get('/:id', obtenerUsuarioPorId);

// POST /api/usuarios - Crear un nuevo usuario
router.post('/', crearUsuario);

// POST /api/usuarios/login - Login de usuario
router.post('/login', loginUsuario);

// POST /api/usuarios/recuperar-password/email - Solicitar recuperación por email
router.post('/recuperar-password/email', solicitarRecuperacionEmail);

// POST /api/usuarios/recuperar-password/telefono - Solicitar recuperación por teléfono
router.post('/recuperar-password/telefono', solicitarRecuperacionTelefono);

// POST /api/usuarios/verificar-codigo-recuperacion - Verificar código de recuperación
router.post('/verificar-codigo-recuperacion', verificarCodigoRecuperacion);

// POST /api/usuarios/cambiar-password-recuperacion - Cambiar contraseña con token
router.post('/cambiar-password-recuperacion', cambiarPasswordRecuperacion);

// PUT /api/usuarios/:id - Actualizar un usuario
router.put('/:id', actualizarUsuario);

// DELETE /api/usuarios/:id - Eliminar un usuario
router.delete('/:id', eliminarUsuario);

module.exports = router;
