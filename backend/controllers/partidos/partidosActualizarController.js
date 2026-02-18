const Partido = require('../../models/Partido');
const Estadistica = require('../../models/Estadistica');

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
      'tipo', 'notas', 'estado'
    ];
    
    camposPermitidos.forEach(campo => {
      if (req.body[campo] !== undefined) {
        partido[campo] = req.body[campo];
      }
    });
    
    await partido.save();
    
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
      tarjetasAmarillas,
      tarjetasRojas,
      minutosJugados,
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
      goles: goles || 0,
      asistencias: asistencias || 0,
      tarjetasAmarillas: tarjetasAmarillas || 0,
      tarjetasRojas: tarjetasRojas || 0,
      minutosJugados: minutosJugados || 0,
      valoracion: valoracion || null
    };
    
    partido.estado = 'finalizado';
    await partido.save();
    
    // Actualizar estadísticas globales del usuario
    await actualizarEstadisticasUsuario(usuarioId, partido);
    
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
 * Función auxiliar para actualizar estadísticas globales
 */
const actualizarEstadisticasUsuario = async (usuarioId, partido) => {
  try {
    let estadistica = await Estadistica.findOne({ usuarioId });
    
    // Si no existe, crear estadística
    if (!estadistica) {
      estadistica = new Estadistica({ usuarioId });
    }
    
    // Incrementar partidos jugados
    estadistica.partidos.jugados += 1;
    
    // Determinar resultado
    const { golesLocal, golesVisitante } = partido.resultado;
    if (golesLocal > golesVisitante) {
      estadistica.partidos.ganados += 1;
    } else if (golesLocal < golesVisitante) {
      estadistica.partidos.perdidos += 1;
    } else {
      estadistica.partidos.empatados += 1;
    }
    
    // Actualizar goles y asistencias
    estadistica.goles.total += partido.estadisticasPersonales.goles || 0;
    estadistica.asistencias += partido.estadisticasPersonales.asistencias || 0;
    
    // Tarjetas
    estadistica.tarjetas.amarillas += partido.estadisticasPersonales.tarjetasAmarillas || 0;
    estadistica.tarjetas.rojas += partido.estadisticasPersonales.tarjetasRojas || 0;
    
    // Minutos jugados
    estadistica.minutosJugados += partido.estadisticasPersonales.minutosJugados || 0;
    
    // Actualizar rachas
    actualizarRachas(estadistica, golesLocal, golesVisitante);
    
    // Recalcular promedios
    estadistica.actualizarGolesPorPartido();
    
    await estadistica.save();
    
  } catch (error) {
    console.error('Error actualizando estadísticas:', error);
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

/**
 * Función auxiliar para actualizar rachas
 */
const actualizarRachas = (estadistica, golesLocal, golesVisitante) => {
  const ganador = golesLocal > golesVisitante;
  const empate = golesLocal === golesVisitante;
  const perdido = golesLocal < golesVisitante;
  
  // Actualizar racha actual
  if (ganador) {
    if (estadistica.rachaActual.tipo === 'victorias') {
      estadistica.rachaActual.cantidad += 1;
    } else {
      estadistica.rachaActual.tipo = 'victorias';
      estadistica.rachaActual.cantidad = 1;
    }
    
    // Actualizar racha sin perder
    if (['victorias', 'empates', 'sin_perder'].includes(estadistica.rachaActual.tipo)) {
      const rachaSinPerder = estadistica.rachaActual.cantidad;
      if (rachaSinPerder > estadistica.mejorRacha.sinPerder) {
        estadistica.mejorRacha.sinPerder = rachaSinPerder;
      }
    }
    
    // Actualizar mejor racha de victorias
    if (estadistica.rachaActual.cantidad > estadistica.mejorRacha.victorias) {
      estadistica.mejorRacha.victorias = estadistica.rachaActual.cantidad;
    }
    
  } else if (empate) {
    if (estadistica.rachaActual.tipo === 'empates') {
      estadistica.rachaActual.cantidad += 1;
    } else {
      estadistica.rachaActual.tipo = 'empates';
      estadistica.rachaActual.cantidad = 1;
    }
  } else if (perdido) {
    if (estadistica.rachaActual.tipo === 'derrotas') {
      estadistica.rachaActual.cantidad += 1;
    } else {
      estadistica.rachaActual.tipo = 'derrotas';
      estadistica.rachaActual.cantidad = 1;
    }
  }
};

module.exports = {
  actualizarPartido,
  registrarResultado,
  eliminarPartido
};
