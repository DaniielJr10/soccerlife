const Usuario = require('../models/Usuario');
const Estadistica = require('../models/Estadistica');

// Obtener todos los usuarios
const obtenerUsuarios = async (req, res) => {
  try {
    const usuarios = await Usuario.find({ activo: true }).select('-password');
    res.json(usuarios);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener usuarios', error: error.message });
  }
};

// Obtener un usuario por ID
const obtenerUsuarioPorId = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.params.id).select('-password');
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json(usuario);
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener usuario', error: error.message });
  }
};

// Crear un nuevo usuario
const crearUsuario = async (req, res) => {
  try {
    const nuevoUsuario = new Usuario(req.body);
    const usuarioGuardado = await nuevoUsuario.save();
    
    // Crear estadística inicial en cero — error aquí no debe bloquear el registro
    try {
      const estadisticaInicial = new Estadistica({
        usuarioId: usuarioGuardado._id
      });
      await estadisticaInicial.save();
      console.log(`📊 Estadísticas inicializadas en CERO para el usuario`);
    } catch (statsError) {
      console.warn(`⚠️ No se pudieron crear estadísticas iniciales: ${statsError.message}`);
      // No es crítico — se crearán cuando el usuario registre su primer dato
    }
    
    console.log(`✅ Usuario registrado: ${usuarioGuardado.email}`);
    
    // No devolver la contraseña en la respuesta
    const { password, ...usuarioSinPassword } = usuarioGuardado.toObject();
    res.status(201).json(usuarioSinPassword);
  } catch (error) {
    if (error.code === 11000) {
      res.status(400).json({ message: 'El email ya está registrado' });
    } else {
      res.status(400).json({ message: 'Error al crear usuario', error: error.message });
    }
  }
};

// Actualizar un usuario
const actualizarUsuario = async (req, res) => {
  try {
    const usuarioActualizado = await Usuario.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true, runValidators: true }
    ).select('-password');
    
    if (!usuarioActualizado) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json(usuarioActualizado);
  } catch (error) {
    res.status(400).json({ message: 'Error al actualizar usuario', error: error.message });
  }
};

// Eliminar un usuario (soft delete)
const eliminarUsuario = async (req, res) => {
  try {
    const usuario = await Usuario.findByIdAndUpdate(
      req.params.id,
      { activo: false },
      { new: true }
    );
    
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json({ message: 'Usuario eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar usuario', error: error.message });
  }
};

// Obtener perfil del usuario autenticado (fuente de verdad: MongoDB)
const obtenerMiPerfil = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.usuarioId).select('-password');
    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    res.json({ success: true, usuario });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener perfil', error: error.message });
  }
};

// Actualizar perfil del usuario autenticado → persiste en MongoDB
const actualizarMiPerfil = async (req, res) => {
  try {
    const camposPermitidos = ['nombre', 'posicion', 'club', 'edad', 'estatura', 'peso', 'telefono', 'numeroJugador'];
    const actualizaciones = {};
    camposPermitidos.forEach(campo => {
      if (req.body[campo] !== undefined && req.body[campo] !== '') {
        actualizaciones[campo] = req.body[campo];
      }
    });

    const usuario = await Usuario.findByIdAndUpdate(
      req.usuarioId,
      actualizaciones,
      { new: true, runValidators: true }
    ).select('-password');

    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }
    console.log(`✅ Perfil actualizado en MongoDB para: ${usuario.email}`);
    res.json({ success: true, message: 'Perfil actualizado correctamente', usuario });
  } catch (error) {
    res.status(400).json({ message: 'Error al actualizar perfil', error: error.message });
  }
};

module.exports = {
  obtenerUsuarios,
  obtenerUsuarioPorId,
  crearUsuario,
  actualizarUsuario,
  eliminarUsuario,
  obtenerMiPerfil,
  actualizarMiPerfil
};
