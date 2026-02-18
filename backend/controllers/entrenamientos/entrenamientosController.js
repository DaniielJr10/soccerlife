const Entrenamiento = require('../../models/Entrenamiento');
const Estadistica = require('../../models/Estadistica');

/**
 * Crear un nuevo entrenamiento
 */
const crearEntrenamiento = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    const {
      fecha,
      duracion,
      tipo,
      ubicacion,
      objetivos,
      habilidadesTrabajadas,
      notas
    } = req.body;
    
    // Validaciones
    if (!fecha || !duracion || !tipo || !ubicacion || !objetivos) {
      return res.status(400).json({ 
        message: 'Faltan campos obligatorios: fecha, duracion, tipo, ubicacion, objetivos' 
      });
    }
    
    // Crear entrenamiento
    const nuevoEntrenamiento = new Entrenamiento({
      usuarioId,
      fecha,
      duracion,
      tipo,
      ubicacion,
      objetivos,
      habilidadesTrabajadas: habilidadesTrabajadas || [],
      notas,
      estado: 'programado'
    });
    
    await nuevoEntrenamiento.save();
    
    res.status(201).json({
      success: true,
      message: 'Entrenamiento creado exitosamente',
      entrenamiento: nuevoEntrenamiento
    });
    
  } catch (error) {
    console.error('Error en crearEntrenamiento:', error);
    res.status(500).json({ 
      message: 'Error al crear entrenamiento', 
      error: error.message 
    });
  }
};

/**
 * Obtener todos los entrenamientos del usuario
 */
const obtenerEntrenamientos = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    const { estado, limit = 50, offset = 0 } = req.query;
    
    const filtros = { usuarioId, activo: true };
    if (estado) filtros.estado = estado;
    
    const entrenamientos = await Entrenamiento.find(filtros)
      .sort({ fecha: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));
    
    const total = await Entrenamiento.countDocuments(filtros);
    
    res.json({
      success: true,
      entrenamientos,
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
    
  } catch (error) {
    console.error('Error en obtenerEntrenamientos:', error);
    res.status(500).json({ 
      message: 'Error al obtener entrenamientos', 
      error: error.message 
    });
  }
};

/**
 * Obtener entrenamientos próximos (programados)
 */
const obtenerEntrenamientosProximos = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    const entrenamientos = await Entrenamiento.find({
      usuarioId,
      estado: 'programado',
      fecha: { $gte: new Date() },
      activo: true
    })
    .sort({ fecha: 1 })
    .limit(20);
    
    res.json({
      success: true,
      entrenamientos
    });
    
  } catch (error) {
    console.error('Error en obtenerEntrenamientosProximos:', error);
    res.status(500).json({ 
      message: 'Error al obtener entrenamientos próximos', 
      error: error.message 
    });
  }
};

/**
 * Obtener entrenamientos anteriores (completados)
 */
const obtenerEntrenamientosAnteriores = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    const { limit = 20 } = req.query;
    
    const entrenamientos = await Entrenamiento.find({
      usuarioId,
      estado: 'completado',
      activo: true
    })
    .sort({ fecha: -1 })
    .limit(parseInt(limit));
    
    res.json({
      success: true,
      entrenamientos
    });
    
  } catch (error) {
    console.error('Error en obtenerEntrenamientosAnteriores:', error);
    res.status(500).json({ 
      message: 'Error al obtener entrenamientos anteriores', 
      error: error.message 
    });
  }
};

/**
 * Obtener un entrenamiento por ID
 */
const obtenerEntrenamientoPorId = async (req, res) => {
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
    
    res.json({
      success: true,
      entrenamiento
    });
    
  } catch (error) {
    console.error('Error en obtenerEntrenamientoPorId:', error);
    res.status(500).json({ 
      message: 'Error al obtener entrenamiento', 
      error: error.message 
    });
  }
};

module.exports = {
  crearEntrenamiento,
  obtenerEntrenamientos,
  obtenerEntrenamientosProximos,
  obtenerEntrenamientosAnteriores,
  obtenerEntrenamientoPorId
};
