const Logro = require('../models/Logro');
const UsuarioLogro = require('../models/UsuarioLogro');
const Estadistica = require('../models/Estadistica');

/**
 * Obtener todos los logros disponibles
 */
const obtenerLogrosDisponibles = async (req, res) => {
  try {
    const logros = await Logro.find({ activo: true }).sort({ rareza: 1, puntos: 1 });
    
    res.json({
      success: true,
      logros
    });
    
  } catch (error) {
    console.error('Error en obtenerLogrosDisponibles:', error);
    res.status(500).json({ 
      message: 'Error al obtener logros disponibles', 
      error: error.message 
    });
  }
};

/**
 * Obtener logros del usuario con progreso
 */
const obtenerLogrosUsuario = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    // Obtener todos los logros disponibles
    const logrosDisponibles = await Logro.find({ activo: true });
    
    // Obtener logros del usuario
    const logrosUsuario = await UsuarioLogro.find({ usuarioId });
    
    // Combinar información
    const logrosConProgreso = logrosDisponibles.map(logro => {
      const logroUsuario = logrosUsuario.find(ul => ul.logroId === logro.logroId);
      
      return {
        ...logro.toObject(),
        desbloqueado: logroUsuario?.desbloqueado || false,
        fechaDesbloqueo: logroUsuario?.fechaDesbloqueo || null,
        progreso: logroUsuario?.progreso || {
          actual: 0,
          requerido: logro.requisito.cantidad
        },
        visto: logroUsuario?.visto || false
      };
    });
    
    res.json({
      success: true,
      logros: logrosConProgreso
    });
    
  } catch (error) {
    console.error('Error en obtenerLogrosUsuario:', error);
    res.status(500).json({ 
      message: 'Error al obtener logros del usuario', 
      error: error.message 
    });
  }
};

/**
 * Verificar y desbloquear logros automáticamente
 */
const verificarLogros = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    // Obtener estadísticas del usuario
    const estadisticas = await Estadistica.findOne({ usuarioId });
    
    if (!estadisticas) {
      return res.json({
        success: true,
        logrosDesbloqueados: [],
        message: 'No hay estadísticas disponibles'
      });
    }
    
    // Obtener todos los logros
    const logrosDisponibles = await Logro.find({ activo: true });
    
    const logrosDesbloqueados = [];
    
    // Verificar cada logro
    for (const logro of logrosDisponibles) {
      // Buscar si el usuario ya tiene este logro
      let usuarioLogro = await UsuarioLogro.findOne({ 
        usuarioId, 
        logroId: logro.logroId 
      });
      
      // Si no existe, crearlo
      if (!usuarioLogro) {
        usuarioLogro = new UsuarioLogro({
          usuarioId,
          logroId: logro.logroId,
          progreso: {
            actual: 0,
            requerido: logro.requisito.cantidad
          },
          desbloqueado: false
        });
      }
      
      // Si ya está desbloqueado, continuar
      if (usuarioLogro.desbloqueado) continue;
      
      // Calcular progreso según el tipo de requisito
      let progresoActual = 0;
      
      switch (logro.requisito.tipo) {
        case 'partidos_jugados':
          progresoActual = estadisticas.partidos.jugados;
          break;
        case 'goles':
          progresoActual = estadisticas.goles.total;
          break;
        case 'asistencias':
          progresoActual = estadisticas.asistencias;
          break;
        case 'victorias':
          progresoActual = estadisticas.partidos.ganados;
          break;
        case 'entrenamientos':
          progresoActual = estadisticas.entrenamientos.completados;
          break;
        case 'racha_victorias':
          if (estadisticas.rachaActual.tipo === 'victorias') {
            progresoActual = estadisticas.rachaActual.cantidad;
          }
          break;
      }
      
      usuarioLogro.progreso.actual = progresoActual;
      
      // Verificar si se desbloqueó
      if (usuarioLogro.verificarDesbloqueo()) {
        logrosDesbloqueados.push({
          ...logro.toObject(),
          fechaDesbloqueo: usuarioLogro.fechaDesbloqueo
        });
      }
      
      await usuarioLogro.save();
    }
    
    res.json({
      success: true,
      logrosDesbloqueados,
      message: logrosDesbloqueados.length > 0 
        ? `¡${logrosDesbloqueados.length} logro(s) desbloqueado(s)!` 
        : 'No hay nuevos logros desbloqueados'
    });
    
  } catch (error) {
    console.error('Error en verificarLogros:', error);
    res.status(500).json({ 
      message: 'Error al verificar logros', 
      error: error.message 
    });
  }
};

module.exports = {
  obtenerLogrosDisponibles,
  obtenerLogrosUsuario,
  verificarLogros
};
