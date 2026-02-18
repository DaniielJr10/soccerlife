const mongoose = require('mongoose');
const Logro = require('../models/Logro');
require('dotenv').config();

/**
 * Script para inicializar logros por defecto en la base de datos
 * Ejecutar: node scripts/inicializarLogros.js
 */

const logrosIniciales = [
  // Logros de Partidos
  {
    logroId: 'primer_partido',
    titulo: 'Primer Paso',
    descripcion: 'Juega tu primer partido',
    icono: '⚽',
    color: '#90EE90',
    categoria: 'partidos',
    requisito: { tipo: 'partidos_jugados', cantidad: 1 },
    puntos: 10,
    rareza: 'Común'
  },
  {
    logroId: 'diez_partidos',
    titulo: 'Veterano',
    descripcion: 'Juega 10 partidos',
    icono: '🏆',
    color: '#87CEEB',
    categoria: 'partidos',
    requisito: { tipo: 'partidos_jugados', cantidad: 10 },
    puntos: 25,
    rareza: 'Raro'
  },
  {
    logroId: 'cincuenta_partidos',
    titulo: 'Profesional',
    descripcion: 'Juega 50 partidos',
    icono: '🎖️',
    color: '#9370DB',
    categoria: 'partidos',
    requisito: { tipo: 'partidos_jugados', cantidad: 50 },
    puntos: 50,
    rareza: 'Épico'
  },
  
  // Logros de Goles
  {
    logroId: 'primer_gol',
    titulo: 'Goleador Nato',
    descripcion: 'Marca tu primer gol',
    icono: '⚡',
    color: '#FFD700',
    categoria: 'goles',
    requisito: { tipo: 'goles', cantidad: 1 },
    puntos: 15,
    rareza: 'Común'
  },
  {
    logroId: 'diez_goles',
    titulo: 'Artillero',
    descripcion: 'Marca 10 goles',
    icono: '🔥',
    color: '#FF6347',
    categoria: 'goles',
    requisito: { tipo: 'goles', cantidad: 10 },
    puntos: 30,
    rareza: 'Raro'
  },
  {
    logroId: 'cincuenta_goles',
    titulo: 'Máquina de Goles',
    descripcion: 'Marca 50 goles',
    icono: '💥',
    color: '#FF4500',
    categoria: 'goles',
    requisito: { tipo: 'goles', cantidad: 50 },
    puntos: 75,
    rareza: 'Épico'
  },
  {
    logroId: 'cien_goles',
    titulo: 'Leyenda Goleadora',
    descripcion: 'Marca 100 goles',
    icono: '👑',
    color: '#FFD700',
    categoria: 'goles',
    requisito: { tipo: 'goles', cantidad: 100 },
    puntos: 150,
    rareza: 'Legendario'
  },
  
  // Logros de Entrenamientos
  {
    logroId: 'primer_entrenamiento',
    titulo: 'Dedicación',
    descripcion: 'Completa tu primer entrenamiento',
    icono: '💪',
    color: '#32CD32',
    categoria: 'entrenamientos',
    requisito: { tipo: 'entrenamientos', cantidad: 1 },
    puntos: 10,
    rareza: 'Común'
  },
  {
    logroId: 'veinte_entrenamientos',
    titulo: 'Disciplinado',
    descripcion: 'Completa 20 entrenamientos',
    icono: '🎯',
    color: '#4169E1',
    categoria: 'entrenamientos',
    requisito: { tipo: 'entrenamientos', cantidad: 20 },
    puntos: 40,
    rareza: 'Raro'
  },
  {
    logroId: 'cien_entrenamientos',
    titulo: 'Máquina de Entrenamiento',
    descripcion: 'Completa 100 entrenamientos',
    icono: '🏋️',
    color: '#8B008B',
    categoria: 'entrenamientos',
    requisito: { tipo: 'entrenamientos', cantidad: 100 },
    puntos: 100,
    rareza: 'Épico'
  },
  
  // Logros de Victorias
  {
    logroId: 'primera_victoria',
    titulo: 'Sabor a Victoria',
    descripcion: 'Gana tu primer partido',
    icono: '🎉',
    color: '#FFD700',
    categoria: 'racha',
    requisito: { tipo: 'victorias', cantidad: 1 },
    puntos: 15,
    rareza: 'Común'
  },
  {
    logroId: 'racha_tres_victorias',
    titulo: 'En Racha',
    descripcion: 'Gana 3 partidos seguidos',
    icono: '🔥',
    color: '#FF8C00',
    categoria: 'racha',
    requisito: { tipo: 'racha_victorias', cantidad: 3 },
    puntos: 35,
    rareza: 'Raro'
  },
  {
    logroId: 'racha_cinco_victorias',
    titulo: 'Imparable',
    descripcion: 'Gana 5 partidos seguidos',
    icono: '⚡',
    color: '#FF4500',
    categoria: 'racha',
    requisito: { tipo: 'racha_victorias', cantidad: 5 },
    puntos: 60,
    rareza: 'Épico'
  },
  {
    logroId: 'racha_diez_victorias',
    titulo: 'Invencible',
    descripcion: 'Gana 10 partidos seguidos',
    icono: '👑',
    color: '#FFD700',
    categoria: 'racha',
    requisito: { tipo: 'racha_victorias', cantidad: 10 },
    puntos: 120,
    rareza: 'Legendario'
  }
];

const inicializarLogros = async () => {
  try {
    // Conectar a MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/soccerlife');
    console.log('✅ Conectado a MongoDB');

    // Limpiar logros existentes (opcional)
    await Logro.deleteMany({});
    console.log('🗑️ Logros anteriores eliminados');

    // Insertar logros uno por uno para ver cual falla
    let logrosCreados = 0;
    for (const logro of logrosIniciales) {
      try {
        await Logro.create(logro);
        logrosCreados++;
        console.log(`✅ Creado: ${logro.titulo}`);
      } catch (error) {
        console.error(`❌ Error con logro "${logro.titulo}":`, error.message);
      }
    }

    console.log(`\n✅ ${logrosCreados} de ${logrosIniciales.length} logros creados`);

    mongoose.connection.close();
    process.exit(0);

  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
};

// Ejecutar
inicializarLogros();
