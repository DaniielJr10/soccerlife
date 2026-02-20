/**
 * Script para actualizar el validador de la colección 'estadisticas' en MongoDB Atlas
 * El validador anterior usaba campos planos (goles, asistencias, partidosJugados)
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
      collMod: 'estadisticas',
      validator: {
        $jsonSchema: {
          bsonType: 'object',
          required: ['usuarioId'],
          properties: {
            usuarioId: {
              bsonType: 'objectId',
              description: 'ID del usuario'
            },
            temporada: {
              bsonType: 'string',
              description: 'Temporada actual'
            },
            partidos: {
              bsonType: 'object',
              description: 'Estadísticas de partidos'
            },
            goles: {
              bsonType: 'object',
              description: 'Estadísticas de goles'
            },
            asistencias: {
              bsonType: 'number',
              description: 'Total de asistencias'
            },
            tarjetas: {
              bsonType: 'object',
              description: 'Tarjetas amarillas y rojas'
            },
            minutosJugados: {
              bsonType: 'number',
              description: 'Minutos totales jugados'
            },
            valoracionPromedio: {
              bsonType: 'number',
              description: 'Valoración promedio'
            },
            entrenamientos: {
              bsonType: 'object',
              description: 'Estadísticas de entrenamientos'
            }
          }
        }
      },
      validationLevel: 'moderate',
      validationAction: 'warn'
    });

    console.log('✅ Validador de la colección "estadisticas" actualizado correctamente');
    console.log('   - Ahora usa estructura anidada: partidos.{jugados,ganados,...}, goles.{total,porPartido}');
    console.log('   - validationAction: warn (no bloquea documentos existentes)');

  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    console.log('🔌 Desconectado de MongoDB');
  }
}

actualizarValidador();
