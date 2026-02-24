const Estadistica = require('../models/Estadistica');
const Partido = require('../models/Partido');

const normalizarNumero = (value) => {
  const n = Number(value);
  return Number.isFinite(n) ? n : 0;
};

const resultadoPartido = (partido) => {
  const golesFavor = normalizarNumero(partido?.resultado?.golesLocal);
  const golesContra = normalizarNumero(partido?.resultado?.golesVisitante);

  if (golesFavor > golesContra) return 'victoria';
  if (golesFavor < golesContra) return 'derrota';
  return 'empate';
};

const calcularRachas = (partidosOrdenados) => {
  const resultados = partidosOrdenados.map(resultadoPartido);

  let mejorVictorias = 0;
  let rachaVictorias = 0;

  let mejorSinPerder = 0;
  let rachaSinPerder = 0;

  for (const r of resultados) {
    if (r === 'victoria') {
      rachaVictorias += 1;
      mejorVictorias = Math.max(mejorVictorias, rachaVictorias);
    } else {
      rachaVictorias = 0;
    }

    if (r === 'derrota') {
      rachaSinPerder = 0;
    } else {
      rachaSinPerder += 1;
      mejorSinPerder = Math.max(mejorSinPerder, rachaSinPerder);
    }
  }

  // Racha actual (según últimos resultados)
  let rachaActual = { tipo: 'ninguna', cantidad: 0 };
  if (resultados.length > 0) {
    const ultimo = resultados[resultados.length - 1];
    let contador = 0;
    for (let i = resultados.length - 1; i >= 0; i -= 1) {
      if (resultados[i] !== ultimo) break;
      contador += 1;
    }

    if (ultimo === 'victoria') rachaActual = { tipo: 'victorias', cantidad: contador };
    if (ultimo === 'empate') rachaActual = { tipo: 'empates', cantidad: contador };
    if (ultimo === 'derrota') rachaActual = { tipo: 'derrotas', cantidad: contador };
  }

  return {
    rachaActual,
    mejorRacha: {
      victorias: mejorVictorias,
      sinPerder: mejorSinPerder,
    },
  };
};

/**
 * Recalcula y persiste las estadísticas acumuladas del usuario.
 * Fuente de verdad: Partidos (finalizados).
 */
const recalcularEstadisticasUsuario = async (usuarioId) => {
  // Partidos que impactan estadísticas: finalizados y activos
  const partidos = await Partido.find({
    usuarioId,
    activo: true,
    estado: 'finalizado',
  }).sort({ fecha: 1, createdAt: 1 });

  let estadistica = await Estadistica.findOne({ usuarioId });
  if (!estadistica) {
    estadistica = new Estadistica({ usuarioId });
  }

  // Reset
  estadistica.partidos = { jugados: 0, ganados: 0, empatados: 0, perdidos: 0 };
  estadistica.goles = { total: 0, porPartido: 0 };
  estadistica.asistencias = 0;
  estadistica.tarjetas = { amarillas: 0, rojas: 0 };
  estadistica.minutosJugados = 0;
  estadistica.valoracionPromedio = 0;
  estadistica.rachaActual = { tipo: 'ninguna', cantidad: 0 };
  estadistica.mejorRacha = { victorias: 0, sinPerder: 0 };

  // Calcular partidos
  let sumaValoraciones = 0;
  let conteoValoraciones = 0;

  for (const partido of partidos) {
    estadistica.partidos.jugados += 1;

    const r = resultadoPartido(partido);
    if (r === 'victoria') estadistica.partidos.ganados += 1;
    if (r === 'empate') estadistica.partidos.empatados += 1;
    if (r === 'derrota') estadistica.partidos.perdidos += 1;

    estadistica.goles.total += normalizarNumero(partido?.estadisticasPersonales?.goles);
    estadistica.asistencias += normalizarNumero(partido?.estadisticasPersonales?.asistencias);
    estadistica.tarjetas.amarillas += normalizarNumero(partido?.estadisticasPersonales?.tarjetasAmarillas);
    estadistica.tarjetas.rojas += normalizarNumero(partido?.estadisticasPersonales?.tarjetasRojas);
    estadistica.minutosJugados += normalizarNumero(partido?.estadisticasPersonales?.minutosJugados);

    const valoracion = partido?.estadisticasPersonales?.valoracion;
    if (valoracion !== null && valoracion !== undefined) {
      const v = Number(valoracion);
      if (Number.isFinite(v)) {
        sumaValoraciones += v;
        conteoValoraciones += 1;
      }
    }
  }

  estadistica.actualizarGolesPorPartido();

  // Valoración promedio (si hay)
  if (conteoValoraciones > 0) {
    estadistica.valoracionPromedio = Number((sumaValoraciones / conteoValoraciones).toFixed(2));
  }

  // Rachas
  const { rachaActual, mejorRacha } = calcularRachas(partidos);
  estadistica.rachaActual = rachaActual;
  estadistica.mejorRacha = mejorRacha;

  await estadistica.save();
  return estadistica;
};

module.exports = {
  recalcularEstadisticasUsuario,
};
