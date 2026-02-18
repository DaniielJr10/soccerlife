const jwt = require('jsonwebtoken');

/**
 * Servicio para generar y validar tokens JWT
 */
class TokenService {
  
  constructor() {
    this.SECRET = process.env.JWT_SECRET || 'secret_key_soccerlife_2026';
    this.EXPIRES_IN = process.env.JWT_EXPIRES_IN || '7d'; // 7 días por defecto
  }
  
  /**
   * Genera un token JWT para un usuario
   * @param {Object} usuario - Objeto con datos del usuario
   * @returns {String} Token JWT
   */
  generarToken(usuario) {
    const payload = {
      userId: usuario._id || usuario.id,
      email: usuario.email,
      nombre: usuario.nombre
    };
    
    return jwt.sign(payload, this.SECRET, {
      expiresIn: this.EXPIRES_IN
    });
  }
  
  /**
   * Verifica y decodifica un token
   * @param {String} token - Token JWT
   * @returns {Object} Datos decodificados del token
   */
  verificarToken(token) {
    try {
      return jwt.verify(token, this.SECRET);
    } catch (error) {
      throw new Error('Token inválido o expirado');
    }
  }
  
  /**
   * Genera un token de refresh (más duración)
   * @param {Object} usuario - Objeto con datos del usuario
   * @returns {String} Refresh token
   */
  generarRefreshToken(usuario) {
    const payload = {
      userId: usuario._id || usuario.id,
      email: usuario.email,
      tipo: 'refresh'
    };
    
    return jwt.sign(payload, this.SECRET, {
      expiresIn: '30d' // 30 días
    });
  }
}

module.exports = new TokenService();
