const Entrenamiento = require('../../models/Entrenamiento');
const Estadistica = require('../../models/Estadistica');

/**
 * Actualizar un entrenamiento
 */
const actualizarEntrenamiento = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const entrenamiento = await Entrenamiento.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!entrenamiento) {
      return res.status(404).json({ message: 'Entrenamiento no encontrado' });
    }
    
    const camposPermitidos = [
      'fecha', 'duracion', 'tipo', 'ubicacion', 'objetivos',
      'habilidadesTrabajadas', 'notas', 'estado'
    ];
    
    camposPermitidos.forEach(campo => {
      if (req.body[campo] !== undefined) {
        entrenamiento[campo] = req.body[campo];
      }
    });
    
    await entrenamiento.save();
    
    res.json({
      success: true,
      message: 'Entrenamiento actualizado exitosamente',
      entrenamiento
    });
    
  } catch (error) {
    console.error('Error en actualizarEntrenamiento:', error);
    res.status(500).json({ 
      message: 'Error al actualizar entrenamiento', 
      error: error.message 
    });
  }
};

/**
 * Marcar entrenamiento como completado
 */
const completarEntrenamiento = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const {
      intensidad,
      valoracion,
      habilidadesTrabajadas,
      notas,
      lesiones
    } = req.body;
    
    const entrenamiento = await Entrenamiento.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!entrenamiento) {
      return res.status(404).json({ message: 'Entrenamiento no encontrado' });
    }
    
    // Actualizar datos del entrenamiento completado
    entrenamiento.estado = 'completado';
    entrenamiento.intensidad = intensidad || 'Media';
    entrenamiento.valoracion = valoracion || null;
    
    if (habilidadesTrabajadas) {
      entrenamiento.habilidadesTrabajadas = habilidadesTrabajadas;
    }
    if (notas) entrenamiento.notas = notas;
    if (lesiones) entrenamiento.lesiones = lesiones;
    
    await entrenamiento.save();
    
    // Actualizar estadísticas del usuario
    await actualizarEstadisticasEntrenamiento(usuarioId, entrenamiento);
    
    res.json({
      success: true,
      message: 'Entrenamiento completado exitosamente',
      entrenamiento
    });
    
  } catch (error) {
    console.error('Error en completarEntrenamiento:', error);
    res.status(500).json({ 
      message: 'Error al completar entrenamiento', 
      error: error.message 
    });
  }
};

/**
 * Función auxiliar para actualizar estadísticas de entrenamientos
 */
const actualizarEstadisticasEntrenamiento = async (usuarioId, entrenamiento) => {
  try {
    let estadistica = await Estadistica.findOne({ usuarioId });
    
    if (!estadistica) {
      estadistica = new Estadistica({ usuarioId });
    }
    
    // Incrementar entrenamientos completados
    estadistica.entrenamientos.completados += 1;
    
    // Sumar horas totales (duracion está en minutos)
    const horas = entrenamiento.duracion / 60;
    estadistica.entrenamientos.horasTotales += horas;
    
    await estadistica.save();
    
  } catch (error) {
    console.error('Error actualizando estadísticas de entrenamiento:', error);
  }
};

/**
 * Eliminar entrenamiento (soft delete)
 */
const eliminarEntrenamiento = async (req, res) => {
  try {
    const { id } = req.params;
    const usuarioId = req.usuarioId;
    
    const entrenamiento = await Entrenamiento.findOne({ 
      _id: id, 
      usuarioId,
      activo: true 
    });
    
    if (!entrenamiento) {
      return res.status(404).json({ message: 'Entrenamiento no encontrado' });
    }
    
    entrenamiento.activo = false;
    await entrenamiento.save();
    
    res.json({
      success: true,
      message: 'Entrenamiento eliminado exitosamente'
    });
    
  } catch (error) {
    console.error('Error en eliminarEntrenamiento:', error);
    res.status(500).json({ 
      message: 'Error al eliminar entrenamiento', 
      error: error.message 
    });
  }
};

module.exports = {
  actualizarEntrenamiento,
  completarEntrenamiento,
  eliminarEntrenamiento
};
