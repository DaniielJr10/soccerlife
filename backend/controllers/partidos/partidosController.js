const Partido = require('../../models/Partido');
const Estadistica = require('../../models/Estadistica');

/**
 * Controlador para crear un nuevo partido
 */
const crearPartido = async (req, res) => {
  try {
    const usuarioId = req.usuarioId; // Del middleware de autenticación
    
    const {
      equipoRival,
      fecha,
      hora,
      lugar,
      tipo,
      competicion,
      notas
    } = req.body;
    
    // Validaciones
    if (!equipoRival || !fecha || !hora) {
      return res.status(400).json({ 
        message: 'Faltan campos obligatorios: equipoRival, fecha, hora' 
      });
    }
    
    // Crear partido
    const nuevoPartido = new Partido({
      usuarioId,
      equipoRival,
      fecha,
      hora,
      lugar,
      tipo: tipo || 'Amistoso',
      competicion: competicion || '',
      estado: 'programado',
      notas
    });
    
    await nuevoPartido.save();
    
    res.status(201).json({
      success: true,
      message: 'Partido creado exitosamente',
      partido: nuevoPartido
    });
    
  } catch (error) {
    console.error('Error en crearPartido:', error);
    res.status(500).json({ 
      message: 'Error al crear partido', 
      error: error.message 
    });
  }
};

/**
 * Obtener todos los partidos del usuario
 */
const obtenerPartidos = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    const { estado, limit = 50, offset = 0 } = req.query;
    
    // Filtros
    const filtros = { usuarioId, activo: true };
    if (estado) filtros.estado = estado;
    
    const partidos = await Partido.find(filtros)
      .sort({ fecha: -1 })
      .limit(parseInt(limit))
      .skip(parseInt(offset));
    
    const total = await Partido.countDocuments(filtros);
    
    res.json({
      success: true,
      partidos,
      total,
      limit: parseInt(limit),
      offset: parseInt(offset)
    });
    
  } catch (error) {
    console.error('Error en obtenerPartidos:', error);
    res.status(500).json({ 
      message: 'Error al obtener partidos', 
      error: error.message 
    });
  }
};

/**
 * Obtener partidos futuros (programados)
 */
const obtenerPartidosFuturos = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    
    const partidos = await Partido.find({
      usuarioId,
      estado: 'programado',
      fecha: { $gte: new Date() },
      activo: true
    })
    .sort({ fecha: 1 }) // Más próximos primero
    .limit(20);
    
    res.json({
      success: true,
      partidos
    });
    
  } catch (error) {
    console.error('Error en obtenerPartidosFuturos:', error);
    res.status(500).json({ 
      message: 'Error al obtener partidos futuros', 
      error: error.message 
    });
  }
};

/**
 * Obtener partidos jugados (finalizados)
 */
const obtenerPartidosJugados = async (req, res) => {
  try {
    const usuarioId = req.usuarioId;
    const { limit = 20 } = req.query;
    
    const partidos = await Partido.find({
      usuarioId,
      estado: 'finalizado',
      activo: true
    })
    .sort({ fecha: -1 }) // Más recientes primero
    .limit(parseInt(limit));
    
    res.json({
      success: true,
      partidos
    });
    
  } catch (error) {
    console.error('Error en obtenerPartidosJugados:', error);
    res.status(500).json({ 
      message: 'Error al obtener partidos jugados', 
      error: error.message 
    });
  }
};

/**
 * Obtener un partido por ID
 */
const obtenerPartidoPorId = async (req, res) => {
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
    
    res.json({
      success: true,
      partido
    });
    
  } catch (error) {
    console.error('Error en obtenerPartidoPorId:', error);
    res.status(500).json({ 
      message: 'Error al obtener partido', 
      error: error.message 
    });
  }
};

module.exports = {
  crearPartido,
  obtenerPartidos,
  obtenerPartidosFuturos,
  obtenerPartidosJugados,
  obtenerPartidoPorId
};
