const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: '*', // Permite todas las fuentes. Puedes restringirlo si lo deseas.
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization']
}));
app.use(express.json());

// Conexión a MongoDB
mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/soccerlife')
.then(() => console.log('Conectado a MongoDB'))
.catch((error) => console.error('Error conectando a MongoDB:', error));

// Rutas
const usuariosRoutes     = require('./routes/usuarios');
const partidosRoutes     = require('./routes/partidos');
const estadisticasRoutes = require('./routes/estadisticas');
const logrosRoutes       = require('./routes/logros');
const torneosRoutes      = require('./routes/torneos');

app.use('/api/usuarios',     usuariosRoutes);
app.use('/api/partidos',     partidosRoutes);
app.use('/api/estadisticas', estadisticasRoutes);
app.use('/api/logros',       logrosRoutes);
app.use('/api/torneos',      torneosRoutes);

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ message: 'API de SoccerLife funcionando correctamente!' });
});

// Iniciar servidor
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Servidor corriendo en puerto ${PORT}`);
  console.log(`Disponible en:`);
  console.log(`- Local: http://localhost:${PORT}`);
  console.log(`- Red: http://192.168.1.45:${PORT}`);
});
