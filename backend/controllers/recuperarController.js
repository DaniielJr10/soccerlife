const Usuario = require('../models/Usuario');
const crypto = require('crypto');

// Almacén temporal para códigos de recuperación (en producción usar Redis o base de datos)
const codigosRecuperacion = new Map();

// Función para generar código de 4 dígitos
const generarCodigoRecuperacion = () => {
  return Math.floor(1000 + Math.random() * 9000).toString(); // 1000-9999
};

// Función para generar token de recuperación
const generarTokenRecuperacion = () => {
  return crypto.randomBytes(32).toString('hex');
};

// Solicitar recuperación de contraseña por email
const solicitarRecuperacionEmail = async (req, res) => {
  try {
    const { email } = req.body;
    
    if (!email) {
      return res.status(400).json({ message: 'Email es requerido' });
    }

    // Verificar si el usuario existe
    const usuario = await Usuario.findOne({ email: email.toLowerCase(), activo: true });
    if (!usuario) {
      return res.status(404).json({ message: 'No existe un usuario con este email' });
    }

    // Generar código de recuperación
    const codigo = generarCodigoRecuperacion();
    const expiracion = Date.now() + 15 * 60 * 1000; // 15 minutos

    // Guardar código en almacén temporal
    codigosRecuperacion.set(email.toLowerCase(), {
      codigo,
      expiracion,
      intentos: 0,
      maxIntentos: 3
    });

    console.log(`📧 Código de recuperación para ${email}: ${codigo}`);
    
    // En producción aquí enviarías el email real
    // await enviarEmailRecuperacion(email, codigo);

    res.json({
      message: 'Código de recuperación enviado a tu email',
      codigo: codigo // Solo para desarrollo - quitar en producción
    });

  } catch (error) {
    console.error('Error en solicitarRecuperacionEmail:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// Solicitar recuperación de contraseña por teléfono
const solicitarRecuperacionTelefono = async (req, res) => {
  try {
    const { telefono } = req.body;
    
    if (!telefono) {
      return res.status(400).json({ message: 'Teléfono es requerido' });
    }

    // Verificar si el usuario existe
    const usuario = await Usuario.findOne({ telefono, activo: true });
    if (!usuario) {
      return res.status(404).json({ message: 'No existe un usuario con este teléfono' });
    }

    // Generar código de recuperación
    const codigo = generarCodigoRecuperacion();
    const expiracion = Date.now() + 15 * 60 * 1000; // 15 minutos

    // Guardar código en almacén temporal
    codigosRecuperacion.set(telefono, {
      codigo,
      expiracion,
      intentos: 0,
      maxIntentos: 3
    });

    console.log(`📱 Código de recuperación para ${telefono}: ${codigo}`);
    
    // En producción aquí enviarías el SMS real
    // await enviarSMSRecuperacion(telefono, codigo);

    res.json({
      message: 'Código de recuperación enviado a tu teléfono',
      codigo: codigo // Solo para desarrollo - quitar en producción
    });

  } catch (error) {
    console.error('Error en solicitarRecuperacionTelefono:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// Verificar código de recuperación
const verificarCodigoRecuperacion = async (req, res) => {
  try {
    const { email, telefono, codigo } = req.body;
    
    if (!codigo) {
      return res.status(400).json({ message: 'Código es requerido' });
    }

    const identificador = email ? email.toLowerCase() : telefono;
    if (!identificador) {
      return res.status(400).json({ message: 'Email o teléfono es requerido' });
    }

    // Verificar si existe código para este identificador
    const datosRecuperacion = codigosRecuperacion.get(identificador);
    if (!datosRecuperacion) {
      return res.status(400).json({ message: 'No se ha solicitado recuperación para este usuario' });
    }

    // Verificar si el código ha expirado
    if (Date.now() > datosRecuperacion.expiracion) {
      codigosRecuperacion.delete(identificador);
      return res.status(400).json({ message: 'El código ha expirado. Solicita uno nuevo' });
    }

    // Verificar intentos máximos
    if (datosRecuperacion.intentos >= datosRecuperacion.maxIntentos) {
      codigosRecuperacion.delete(identificador);
      return res.status(400).json({ message: 'Máximo de intentos excedido. Solicita un nuevo código' });
    }

    // Verificar código
    if (datosRecuperacion.codigo !== codigo) {
      datosRecuperacion.intentos++;
      return res.status(400).json({ 
        message: `Código incorrecto. Intentos restantes: ${datosRecuperacion.maxIntentos - datosRecuperacion.intentos}` 
      });
    }

    // Código correcto - generar token de recuperación
    const token = generarTokenRecuperacion();
    const expiracionToken = Date.now() + 30 * 60 * 1000; // 30 minutos

    // Guardar token y eliminar código
    codigosRecuperacion.delete(identificador);
    codigosRecuperacion.set(`token_${token}`, {
      identificador,
      expiracion: expiracionToken
    });

    res.json({
      message: 'Código verificado correctamente',
      token
    });

  } catch (error) {
    console.error('Error en verificarCodigoRecuperacion:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

// Cambiar contraseña con token de recuperación
const cambiarPasswordRecuperacion = async (req, res) => {
  try {
    const { token, nuevaPassword } = req.body;
    
    if (!token || !nuevaPassword) {
      return res.status(400).json({ message: 'Token y nueva contraseña son requeridos' });
    }

    if (nuevaPassword.length < 6) {
      return res.status(400).json({ message: 'La contraseña debe tener al menos 6 caracteres' });
    }

    // Verificar token
    const datosToken = codigosRecuperacion.get(`token_${token}`);
    if (!datosToken) {
      return res.status(400).json({ message: 'Token inválido o expirado' });
    }

    // Verificar si el token ha expirado
    if (Date.now() > datosToken.expiracion) {
      codigosRecuperacion.delete(`token_${token}`);
      return res.status(400).json({ message: 'Token expirado' });
    }

    // Buscar usuario por email o teléfono
    const identificador = datosToken.identificador;
    let usuario;
    
    if (identificador.includes('@')) {
      usuario = await Usuario.findOne({ email: identificador, activo: true });
    } else {
      usuario = await Usuario.findOne({ telefono: identificador, activo: true });
    }

    if (!usuario) {
      return res.status(404).json({ message: 'Usuario no encontrado' });
    }

    // Actualizar contraseña
    usuario.password = nuevaPassword;
    await usuario.save();

    // Eliminar token
    codigosRecuperacion.delete(`token_${token}`);

    res.json({
      message: 'Contraseña cambiada exitosamente'
    });

  } catch (error) {
    console.error('Error en cambiarPasswordRecuperacion:', error);
    res.status(500).json({ message: 'Error interno del servidor' });
  }
};

module.exports = {
  solicitarRecuperacionEmail,
  solicitarRecuperacionTelefono,
  verificarCodigoRecuperacion,
  cambiarPasswordRecuperacion
};