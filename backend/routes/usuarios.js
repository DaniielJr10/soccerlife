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

// GET /api/usuarios - Obtener todos los usuarios
router.get('/', obtenerUsuarios);

// GET /api/usuarios/:id - Obtener un usuario por ID
router.get('/:id', obtenerUsuarioPorId);

// POST /api/usuarios - Crear un nuevo usuario
router.post('/', crearUsuario);

// POST /api/usuarios/login - Login de usuario
router.post('/login', loginUsuario);

// PUT /api/usuarios/:id - Actualizar un usuario
router.put('/:id', actualizarUsuario);

// DELETE /api/usuarios/:id - Eliminar un usuario
router.delete('/:id', eliminarUsuario);

module.exports = router;
