const Estadistica = require('../models/Estadistica');

/**
 * Obtener estadísticas del usuario
 */
const obtenerEstadisticas = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    let estadistica = await Estadistica.findOne({ usuarioId });
    
    // Si no existe, crear estadística inicial
    if (!estadistica) {
      estadistica = new Estadistica({ usuarioId });
      await estadistica.save();
    }
    
    res.json({
      success: true,
      estadisticas: estadistica
    });
    
  } catch (error) {
    console.error('Error en obtenerEstadisticas:', error);
    res.status(500).json({ 
      message: 'Error al obtener estadísticas', 
      error: error.message 
    });
  }
};

/**
 * Actualizar estadísticas manualmente (admin)
 */
const actualizarEstadisticas = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    let estadistica = await Estadistica.findOne({ usuarioId });
    
    if (!estadistica) {
      estadistica = new Estadistica({ usuarioId });
    }
    
    // Actualizar campos permitidos
    const camposPermitidos = [
      'temporada',
      'partidos',
      'goles',
      'asistencias',
      'tarjetas',
      'minutosJugados',
      'valoracionPromedio',
      'rachaActual',
      'mejorRacha'
    ];
    
    camposPermitidos.forEach(campo => {
      if (req.body[campo] !== undefined) {
        if (typeof req.body[campo] === 'object') {
          estadistica[campo] = { ...estadistica[campo], ...req.body[campo] };
        } else {
          estadistica[campo] = req.body[campo];
        }
      }
    });
    
    // Recalcular promedios
    estadistica.actualizarGolesPorPartido();
    
    await estadistica.save();
    
    res.json({
      success: true,
      message: 'Estadísticas actualizadas exitosamente',
      estadisticas: estadistica
    });
    
  } catch (error) {
    console.error('Error en actualizarEstadisticas:', error);
    res.status(500).json({ 
      message: 'Error al actualizar estadísticas', 
      error: error.message 
    });
  }
};

/**
 * Resetear estadísticas (nueva temporada)
 */
const resetearEstadisticas = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    const { temporada } = req.body;
    
    if (!temporada) {
      return res.status(400).json({ 
        message: 'Debes especificar el nombre de la nueva temporada' 
      });
    }
    
    let estadistica = await Estadistica.findOne({ usuarioId });
    
    if (!estadistica) {
      return res.status(404).json({ message: 'Estadísticas no encontradas' });
    }
    
    // Guardar mejores rachas antes de resetear
    const mejorRachaVictorias = Math.max(
      estadistica.mejorRacha.victorias,
      estadistica.rachaActual.tipo === 'victorias' ? estadistica.rachaActual.cantidad : 0
    );
    
    const mejorRachaSinPerder = Math.max(
      estadistica.mejorRacha.sinPerder,
      estadistica.rachaActual.tipo === 'sin_perder' ? estadistica.rachaActual.cantidad : 0
    );
    
    // Resetear estadísticas
    estadistica.temporada = temporada;
    estadistica.partidos = { jugados: 0, ganados: 0, empatados: 0, perdidos: 0 };
    estadistica.goles = { total: 0, porPartido: 0 };
    estadistica.asistencias = 0;
    estadistica.tarjetas = { amarillas: 0, rojas: 0 };
    estadistica.minutosJugados = 0;
    estadistica.valoracionPromedio = 0;
    estadistica.rachaActual = { tipo: 'ninguna', cantidad: 0 };
    estadistica.mejorRacha = {
      victorias: mejorRachaVictorias,
      sinPerder: mejorRachaSinPerder
    };
    
    await estadistica.save();
    
    res.json({
      success: true,
      message: `Estadísticas reseteadas para la temporada ${temporada}`,
      estadisticas: estadistica
    });
    
  } catch (error) {
    console.error('Error en resetearEstadisticas:', error);
    res.status(500).json({ 
      message: 'Error al resetear estadísticas', 
      error: error.message 
    });
  }
};

module.exports = {
  obtenerEstadisticas,
  actualizarEstadisticas,
  resetearEstadisticas
};
