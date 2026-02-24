const Partido = require('../../models/Partido');
const { recalcularEstadisticasUsuario } = require('../../services/estadisticasRecalculoService');

/**
 * Actualizar información de un partido
 */
const actualizarPartido = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const partido = await Partido.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!partido) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    
    // Actualizar solo campos permitidos
    const camposPermitidos = [
      'equipoRival', 'fecha', 'hora', 'lugar',
      'tipo', 'competicion', 'notas', 'estado'
    ];
    
    camposPermitidos.forEach(campo => {
      if (req.body[campo] !== undefined) {
        partido[campo] = req.body[campo];
      }
    });
    
    await partido.save();

    // Mantener estadísticas consistentes ante cambios
    await recalcularEstadisticasUsuario(usuarioId);
    
    res.json({
      success: true,
      message: 'Partido actualizado exitosamente',
      partido
    });
    
  } catch (error) {
    console.error('Error en actualizarPartido:', error);
    res.status(500).json({ 
      message: 'Error al actualizar partido', 
      error: error.message 
    });
  }
};

/**
 * Registrar resultado de un partido
 */
const registrarResultado = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const {
      golesLocal,
      golesVisitante,
      goles,
      asistencias,
      remates,
      rematesAlArco,
      pasesCompletados,
      pasesFallidos,
      regatesExitosos,
      regatesFallidos,
      faltasCometidas,
      faltasRecibidas,
      tarjetasAmarillas,
      tarjetasRojas,
      minutosJugados,
      posicion,
      valoracion
    } = req.body;
    
    const partido = await Partido.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!partido) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    
    // Actualizar resultado
    partido.resultado = {
      golesLocal: golesLocal || 0,
      golesVisitante: golesVisitante || 0
    };
    
    // Actualizar estadísticas personales
    partido.estadisticasPersonales = {
      posicion: posicion || '',
      goles: goles || 0,
      asistencias: asistencias || 0,
      remates: remates || 0,
      rematesAlArco: rematesAlArco || 0,
      pasesCompletados: pasesCompletados || 0,
      pasesFallidos: pasesFallidos || 0,
      regatesExitosos: regatesExitosos || 0,
      regatesFallidos: regatesFallidos || 0,
      faltasCometidas: faltasCometidas || 0,
      faltasRecibidas: faltasRecibidas || 0,
      tarjetasAmarillas: tarjetasAmarillas || 0,
      tarjetasRojas: tarjetasRojas || 0,
      minutosJugados: minutosJugados || 0,
      valoracion: valoracion || null
    };
    
    partido.estado = 'finalizado';
    await partido.save();

    // Recalcular estadísticas globales para evitar doble conteo/desincronización
    await recalcularEstadisticasUsuario(usuarioId);
    
    res.json({
      success: true,
      message: 'Resultado registrado exitosamente',
      partido
    });
    
  } catch (error) {
    console.error('Error en registrarResultado:', error);
    res.status(500).json({ 
      message: 'Error al registrar resultado', 
      error: error.message 
    });
  }
};

/**
 * Eliminar un partido (soft delete)
 */
const eliminarPartido = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const partido = await Partido.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!partido) {
      return res.status(404).json({ message: 'Partido no encontrado' });
    }
    
    partido.activo = false;
    await partido.save();

    // Mantener estadísticas consistentes ante eliminaciones
    await recalcularEstadisticasUsuario(usuarioId);
    
    res.json({
      success: true,
      message: 'Partido eliminado exitosamente'
    });
    
  } catch (error) {
    console.error('Error en eliminarPartido:', error);
    res.status(500).json({ 
      message: 'Error al eliminar partido', 
      error: error.message 
    });
  }
};

module.exports = {
  actualizarPartido,
  registrarResultado,
  eliminarPartido
};
