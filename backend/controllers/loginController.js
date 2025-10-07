const Usuario = require('../models/Usuario');

// Login de usuario
const loginUsuario = async (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ message: 'Email y contraseña son requeridos' });
    }
    
    // Buscar usuario por email y que esté activo
    const usuario = await Usuario.findOne({ email, activo: true });
    
    if (!usuario) {
      return res.status(401).json({ message: 'Usuario o contraseña incorrectos' });
    }
    
    // Comparar contraseñas (sin hash por ahora)
    if (usuario.password !== password) {
      return res.status(401).json({ message: 'Usuario o contraseña incorrectos' });
    }
    
    // Login exitoso - no devolver la contraseña
    const { password: _, ...usuarioSinPassword } = usuario.toObject();
    
    res.json({ 
      success: true, 
      message: 'Inicio de sesión exitoso',
      usuario: usuarioSinPassword 
    });
    
  } catch (error) {
    res.status(500).json({ message: 'Error al iniciar sesión', error: error.message });
  }
};

module.exports = {
  loginUsuario
};
