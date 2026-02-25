const Torneo = require('../models/Torneo');

// ── Crear torneo ─────────────────────────────────────────────────────────────
const crearTorneo = async (req, res) => {
  try {
    const { nombre, descripcion, fechaInicio, fechaFin, estado, colorHex } = req.body;
    if (!nombre) return res.status(400).json({ message: 'El nombre es obligatorio.' });

    const torneo = await Torneo.create({
      usuarioId: req.usuarioId,
      nombre,
      descripcion,
      fechaInicio: fechaInicio || null,
      fechaFin:    fechaFin    || null,
      estado:      estado      || 'activo',
      colorHex:    colorHex    || '#00D4AA',
    });

    res.status(201).json({ message: 'Torneo creado.', torneo });
  } catch (error) {
    res.status(500).json({ message: 'Error al crear torneo.', error: error.message });
  }
};

// ── Obtener todos los torneos del usuario ────────────────────────────────────
const obtenerTorneos = async (req, res) => {
  try {
    const torneos = await Torneo.find({ usuarioId: req.usuarioId, activo: true })
      .sort({ createdAt: -1 });
    res.json({ torneos });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener torneos.', error: error.message });
  }
};

// ── Obtener torneo por ID ────────────────────────────────────────────────────
const obtenerTorneoPorId = async (req, res) => {
  try {
    const torneo = await Torneo.findOne({ _id: req.params.id, usuarioId: req.usuarioId });
    if (!torneo) return res.status(404).json({ message: 'Torneo no encontrado.' });
    res.json({ torneo });
  } catch (error) {
    res.status(500).json({ message: 'Error al obtener torneo.', error: error.message });
  }
};

// ── Actualizar torneo ────────────────────────────────────────────────────────
const actualizarTorneo = async (req, res) => {
  try {
    const { nombre, descripcion, fechaInicio, fechaFin, estado, colorHex } = req.body;
    const torneo = await Torneo.findOneAndUpdate(
      { _id: req.params.id, usuarioId: req.usuarioId },
      { nombre, descripcion, fechaInicio, fechaFin, estado, colorHex },
      { new: true, runValidators: true }
    );
    if (!torneo) return res.status(404).json({ message: 'Torneo no encontrado.' });
    res.json({ message: 'Torneo actualizado.', torneo });
  } catch (error) {
    res.status(500).json({ message: 'Error al actualizar torneo.', error: error.message });
  }
};

// ── Eliminar torneo (soft delete) ────────────────────────────────────────────
const eliminarTorneo = async (req, res) => {
  try {
    const torneo = await Torneo.findOneAndUpdate(
      { _id: req.params.id, usuarioId: req.usuarioId },
      { activo: false },
      { new: true }
    );
    if (!torneo) return res.status(404).json({ message: 'Torneo no encontrado.' });
    res.json({ message: 'Torneo eliminado.' });
  } catch (error) {
    res.status(500).json({ message: 'Error al eliminar torneo.', error: error.message });
  }
};

module.exports = {
  crearTorneo,
  obtenerTorneos,
  obtenerTorneoPorId,
  actualizarTorneo,
  eliminarTorneo,
};
