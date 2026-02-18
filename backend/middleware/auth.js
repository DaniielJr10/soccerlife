const jwt = require('jsonwebtoken');

/**
 * Middleware de Autenticación con JWT
 * Verifica que el token sea válido y extrae el usuarioId
 */
const verificarToken = (req, res, next) => {
  try {
    // Obtener token del header
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (!token) {
      return res.status(401).json({ 
        message: 'Acceso denegado. No se proporcionó token de autenticación.' 
      });
    }

    // Verificar token
    const JWT_SECRET = process.env.JWT_SECRET || 'secret_key_soccerlife_2026';
    const decoded = jwt.verify(token, JWT_SECRET);
    
    // Agregar userId al request para usar en controladores
    req.usuarioId = decoded.userId;
    req.email = decoded.email;
    
    next();
    
  } catch (error) {
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ message: 'Token inválido.' });
    }
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ message: 'Token expirado. Inicia sesión nuevamente.' });
    }
    return res.status(500).json({ message: 'Error en la autenticación.' });
  }
};

/**
 * Middleware opcional - No falla si no hay token
 * Útil para endpoints que funcionan con o sin autenticación
 */
const verificarTokenOpcional = (req, res, next) => {
  try {
    const token = req.header('Authorization')?.replace('Bearer ', '');
    
    if (token) {
      const JWT_SECRET = process.env.JWT_SECRET || 'secret_key_soccerlife_2026';
      const decoded = jwt.verify(token, JWT_SECRET);
      req.usuarioId = decoded.userId;
      req.email = decoded.email;
    }
    
    next();
    
  } catch (error) {
    // Si hay error, continuar sin usuario autenticado
    next();
  }
};

module.exports = {
  verificarToken,
  verificarTokenOpcional
};
