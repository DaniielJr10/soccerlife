/**
 * Script para actualizar el validador de la colección 'partidos' en MongoDB Atlas
 * El validador anterior usaba campos incompatibles (equipoA, equipoB, jugadores)
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
      collMod: 'partidos',
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['usuarioId', 'equipoRival', 'fecha', 'hora', 'lugar'],
          properties: {
            usuarioId: {
              bsonType: 'objectId',
              description: 'ID del usuario dueño del partido'
            },
            equipoRival: {
              bsonType: 'string',
              description: 'Nombre del equipo rival'
            },
            fecha: {
              bsonType: 'date',
              description: 'Fecha del partido'
            },
            hora: {
              bsonType: 'string',
              description: 'Hora del partido en formato HH:mm'
            },
            lugar: {
              bsonType: 'string',
              description: 'Lugar del partido'
            },
            tipo: {
              bsonType: 'string',
              enum: ['Amistoso', 'Torneo', 'Liga', 'Copa', 'Entrenamiento'],
              description: 'Tipo de partido'
            },
            estado: {
              bsonType: 'string',
              enum: ['programado', 'en_curso', 'finalizado', 'cancelado'],
              description: 'Estado del partido'
            },
            notas: {
              bsonType: 'string',
              description: 'Notas adicionales'
            },
            activo: {
              bsonType: 'bool',
              description: 'Si el partido está activo'
            }
          }
        }
      },
      validationLevel: 'moderate',
      validationAction: 'warn'
    });

    console.log('✅ Validador de la colección "partidos" actualizado correctamente');
    console.log('   - Ahora usa: usuarioId, equipoRival, fecha, hora, lugar');
    console.log('   - validationAction: warn (no bloquea documentos existentes)');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Desconectado de MongoDB');
  }
}

actualizarValidador();
