import 'package:flutter/material.dart';
import 'logros.dart';
// import 'dart:math' as math;

/// Página de estadísticas del jugador donde puede ver su rendimiento
/// Incluye goles, asistencias, partidos jugados, y gráficos de progreso
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage>
    with TickerProviderStateMixin {
  // Controladores para animaciones
  //

  //

  // Datos de estadísticas (en producción vendrían de una API)
  final Map<String, dynamic> _estadisticasTemporada = {
    'partidos_jugados': 28,
    'partidos_ganados': 18,
    'partidos_empatados': 7,
    'partidos_perdidos': 3,
    'goles': 15,
    'asistencias': 8,
    'tarjetas_amarillas': 3,
    'tarjetas_rojas': 0,
    'minutos_jugados': 2340,
    'rating_promedio': 7.8,
  };







  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
  body: _buildEstadisticasGenerales(),
    );
  }

  /// Construye la barra de aplicación personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'Estadísticas',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      // Sin leading (flecha) ni fondo
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: _compartirEstadisticas,
        ),
      ],
    );
  }


  /// Construye la vista de estadísticas generales
  Widget _buildEstadisticasGenerales() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildResumenCard(),
          const SizedBox(height: 16),
          _buildEstadisticasGrid(),
          const SizedBox(height: 16),
          _buildRendimientoCard(),
          const SizedBox(height: 16),
          _buildDisciplinaCard(),
          const SizedBox(height: 20),
          _buildTarjetaExtra(),
          const SizedBox(height: 20),

        ],
      ),
    );
  }

  /// Construye la tarjeta de resumen principal
  Widget _buildResumenCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00f5ff),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(child: _buildMiniCard('Partidos', '${_estadisticasTemporada['partidos_jugados']}')),
              const SizedBox(width: 10),
              Expanded(child: _buildMiniCard('Goles', '${_estadisticasTemporada['goles']}')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMiniCard('Asistencias', '${_estadisticasTemporada['asistencias']}')),
              const SizedBox(width: 10),
              Expanded(child: _buildMiniCard('Entrenamientos', '${_estadisticasTemporada['entrenamientos'] ?? 12}')),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye una tarjeta pequeña para cada estadística
  Widget _buildMiniCard(String label, String value) {
    return Card(
      color: Colors.white,
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 80),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0066ff),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la grilla de estadísticas detalladas
  Widget _buildEstadisticasGrid() {
  return const SizedBox.shrink();
  }



  /// Construye la tarjeta de rendimiento
  Widget _buildRendimientoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Rendimiento por Partidos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildRendimientoItem(
                  'Ganados',
                  _estadisticasTemporada['partidos_ganados'],
                  _estadisticasTemporada['partidos_jugados'],
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRendimientoItem(
                  'Empatados',
                  _estadisticasTemporada['partidos_empatados'],
                  _estadisticasTemporada['partidos_jugados'],
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRendimientoItem(
                  'Perdidos',
                  _estadisticasTemporada['partidos_perdidos'],
                  _estadisticasTemporada['partidos_jugados'],
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de rendimiento
  Widget _buildRendimientoItem(String label, int value, int total, Color color) {
    return Column(
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Construye la tarjeta de disciplina
  Widget _buildDisciplinaCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Disciplina',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDisciplinaItem(
                  'T. Amarillas',
                  _estadisticasTemporada['tarjetas_amarillas'],
                  Colors.yellow[700]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDisciplinaItem(
                  'T. Rojas',
                  _estadisticasTemporada['tarjetas_rojas'],
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de disciplina
  Widget _buildDisciplinaItem(String label, int value, Color color) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.black26, width: 1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }



  /// Función para compartir estadísticas
  void _compartirEstadisticas() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartiendo estadísticas...'),
        backgroundColor: Color(0xFF00f5ff),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Construye la tarjeta extra con navegación a logros y habilidades
  Widget _buildTarjetaExtra() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mas del Jugador',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1a1a2e),
            ),
          ),
          const SizedBox(height: 8),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LogrosPage(),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.emoji_events, color: Colors.deepPurple, size: 32),
                          SizedBox(height: 8),
                          Text('Logros', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {},
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.deepPurple, size: 32),
                          SizedBox(height: 8),
                          Text('Habilidades', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


