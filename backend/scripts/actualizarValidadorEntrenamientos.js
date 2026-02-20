/**
 * Script para actualizar el validador de la colección 'entrenamientos' en MongoDB Atlas
 * El validador anterior usaba campos incompatibles (jugadores como array)
 * Este script lo corrige para que coincida con el modelo actual del backend
 */

const mongoose = require('mongoose');
require('dotenv').config();

async function actualizarValidador() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Conectado a MongoDB Atlas');

    const db = mongoose.connection.db;

    await db.command({
      collMod: 'entrenamientos',
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['usuarioId', 'fecha', 'duracion', 'tipo', 'ubicacion', 'objetivos'],
          properties: {
            usuarioId: {
              bsonType: 'objectId',
              description: 'ID del usuario dueño del entrenamiento'
            },
            fecha: {
              bsonType: 'date',
              description: 'Fecha del entrenamiento'
            },
            duracion: {
              bsonType: 'number',
              minimum: 15,
              maximum: 300,
              description: 'Duración en minutos'
            },
            tipo: {
              bsonType: 'string',
              enum: ['Técnico', 'Físico', 'Táctico', 'Estratégico', 'Recuperación', 'Completo'],
              description: 'Tipo de entrenamiento'
            },
            ubicacion: {
              bsonType: 'string',
              description: 'Ubicación del entrenamiento'
            },
            objetivos: {
              bsonType: 'string',
              description: 'Objetivos del entrenamiento'
            },
            estado: {
              bsonType: 'string',
              enum: ['programado', 'en_curso', 'completado', 'cancelado'],
              description: 'Estado del entrenamiento'
            },
            intensidad: {
              bsonType: 'string',
              enum: ['Baja', 'Media', 'Alta', 'Muy Alta'],
              description: 'Intensidad del entrenamiento'
            },
            habilidadesTrabajadas: {
              bsonType: 'array',
              description: 'Habilidades trabajadas',
              items: { bsonType: 'string' }
            },
            notas: {
              bsonType: 'string',
              description: 'Notas adicionales'
            },
            activo: {
              bsonType: 'bool',
              description: 'Si el entrenamiento está activo'
            }
          }
        }
      },
      validationLevel: 'moderate',
      validationAction: 'warn'
    });

    console.log('✅ Validador de la colección "entrenamientos" actualizado correctamente');
    console.log('   - Ahora usa: usuarioId, fecha, duracion, tipo, ubicacion, objetivos');
    console.log('   - validationAction: warn (no bloquea documentos existentes)');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Desconectado de MongoDB');
  }
}

actualizarValidador();
