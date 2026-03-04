const Usuario = require('../models/Usuario');
const Estadistica = require('../models/Estadistica');

// POST /usuarios/cambiar-password — cambia la contraseña del usuario autenticado
const cambiarPassword = async (req, res) => {
  try {
    const { passwordActual, passwordNueva } = req.body;
    if (!passwordActual || !passwordNueva) {
      return res.status(400).json({ message: 'Se requieren passwordActual y passwordNueva' });
    }
    if (passwordNueva.length < 8) {
      return res.status(400).json({ message: 'La nueva contraseña debe tener al menos 8 caracteres' });
    }
    const usuario = await Usuario.findById(req.usuarioId).select('password');
    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });
    if (usuario.password !== passwordActual) {
      return res.status(401).json({ message: 'La contraseña actual es incorrecta' });
    }
    await Usuario.findByIdAndUpdate(req.usuarioId, { password: passwordNueva });
    console.log(`🔑 Contraseña cambiada para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'Contraseña actualizada correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al cambiar contraseña', error: error.message });
  }
};

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

// ── Carta FIFA ────────────────────────────────────────────────────────────────

// GET /usuarios/carta-fifa — devuelve la carta del usuario autenticado
const obtenerCartaFifa = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.usuarioId).select('cartaFifa');
    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });
    res.json({ success: true, cartaFifa: usuario.cartaFifa ?? null });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener carta FIFA', error: error.message });
  }
};

// PUT /usuarios/carta-fifa — guarda/actualiza la carta (crea si no existía)
const guardarCartaFifa = async (req, res) => {
  try {
    const { nombre, posicion, overall, ritmo, tiro, pase, regate, defensa,
            fisico, contacto, club, nacionalidad, imagenBase64 } = req.body;

    const usuario = await Usuario.findByIdAndUpdate(
      req.usuarioId,
      {
        cartaFifa: {
          nombre, posicion, overall, ritmo, tiro, pase,
          regate, defensa, fisico, contacto, club,
          nacionalidad, imagenBase64,
        },
      },
      { new: true, runValidators: true }
    ).select('cartaFifa');

    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });
    console.log(`🃏 Carta FIFA guardada para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'Carta FIFA guardada', cartaFifa: usuario.cartaFifa });
  } catch (error) {
    res.status(400).json({ message: 'Error al guardar carta FIFA', error: error.message });
  }
};

// DELETE /usuarios/carta-fifa — elimina la carta del usuario
const eliminarCartaFifa = async (req, res) => {
  try {
    await Usuario.findByIdAndUpdate(req.usuarioId, { $unset: { cartaFifa: '' } });
    console.log(`🗑️ Carta FIFA eliminada para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'Carta FIFA eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar carta FIFA', error: error.message });
  }
};

// ── CV en PDF ─────────────────────────────────────────────────────────────────

// GET /usuarios/cv — devuelve si el CV existe y su nombre (no los bytes)
const obtenerInfoCv = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.usuarioId).select('cvNombre');
    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });
    res.json({
      success: true,
      existe: !!usuario.cvNombre,
      cvNombre: usuario.cvNombre ?? null,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener info del CV', error: error.message });
  }
};

// POST /usuarios/cv — guarda el PDF (base64) del usuario
const guardarCv = async (req, res) => {
  try {
    const { cvBase64, cvNombre } = req.body;
    if (!cvBase64 || !cvNombre) {
      return res.status(400).json({ message: 'Faltan campos: cvBase64 y cvNombre son requeridos' });
    }

    await Usuario.findByIdAndUpdate(req.usuarioId, { cvBase64, cvNombre });
    console.log(`📄 CV guardado para usuario ${req.usuarioId}: ${cvNombre}`);
    res.json({ success: true, message: 'CV guardado correctamente', cvNombre });
  } catch (error) {
    res.status(400).json({ message: 'Error al guardar CV', error: error.message });
  }
};

// DELETE /usuarios/cv — elimina el CV del usuario
const eliminarCv = async (req, res) => {
  try {
    await Usuario.findByIdAndUpdate(req.usuarioId, { $unset: { cvBase64: '', cvNombre: '' } });
    console.log(`🗑️ CV eliminado para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'CV eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar CV', error: error.message });
  }
};

// ── Foto de Perfil ────────────────────────────────────────────────────────────────

// GET /usuarios/foto-perfil— devuelve la foto si existe
const obtenerFotoPerfil = async (req, res) => {
  try {
    const usuario = await Usuario.findById(req.usuarioId).select('fotoPerfil');
    if (!usuario) return res.status(404).json({ message: 'Usuario no encontrado' });
    res.json({
      success: true,
      existe: !!usuario.fotoPerfil,
      fotoPerfil: usuario.fotoPerfil ?? null,
    });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener foto de perfil', error: error.message });
  }
};

// PUT /usuarios/foto-perfil — guarda/reemplaza la foto (base64)
const guardarFotoPerfil = async (req, res) => {
  try {
    const { fotoBase64 } = req.body;
    if (!fotoBase64) {
      return res.status(400).json({ message: 'El campo fotoBase64 es requerido' });
    }
    // Validación básica: debe ser base64 de imagen
    if (!fotoBase64.startsWith('data:image') && fotoBase64.length < 50) {
      return res.status(400).json({ message: 'Formato de imagen inválido' });
    }
    await Usuario.findByIdAndUpdate(req.usuarioId, { fotoPerfil: fotoBase64 });
    console.log(`📸 Foto de perfil guardada para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'Foto de perfil guardada correctamente' });
  } catch (error) {
    res.status(400).json({ message: 'Error al guardar foto de perfil', error: error.message });
  }
};

// DELETE /usuarios/foto-perfil — elimina la foto del usuario
const eliminarFotoPerfil = async (req, res) => {
  try {
    await Usuario.findByIdAndUpdate(req.usuarioId, { $unset: { fotoPerfil: '' } });
    console.log(`🗑️ Foto de perfil eliminada para usuario ${req.usuarioId}`);
    res.json({ success: true, message: 'Foto de perfil eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar foto de perfil', error: error.message });
  }
};

module.exports = {
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
  cambiarPassword,
};
