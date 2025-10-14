import 'package:flutter/material.dart';
import 'dart:math' as math;

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
  late AnimationController _animationController;
  late AnimationController _chartAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _chartAnimation;

  // Índice de la pestaña seleccionada
  int _selectedTabIndex = 0;

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

  final List<Map<String, dynamic>> _estadisticasMensuales = [
    {'mes': 'Ene', 'goles': 2, 'asistencias': 1, 'partidos': 4},
    {'mes': 'Feb', 'goles': 3, 'asistencias': 2, 'partidos': 5},
    {'mes': 'Mar', 'goles': 1, 'asistencias': 1, 'partidos': 3},
    {'mes': 'Abr', 'goles': 4, 'asistencias': 2, 'partidos': 4},
    {'mes': 'May', 'goles': 2, 'asistencias': 1, 'partidos': 4},
    {'mes': 'Jun', 'goles': 3, 'asistencias': 1, 'partidos': 4},
    {'mes': 'Jul', 'goles': 0, 'asistencias': 0, 'partidos': 2},
    {'mes': 'Ago', 'goles': 0, 'asistencias': 0, 'partidos': 2},
  ];

  @override
  void initState() {
    super.initState();
    
    // Configuración de animaciones
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _chartAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _chartAnimationController, curve: Curves.easeOutBack),
    );

    // Iniciar animaciones
    _animationController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      _chartAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                children: [
                  _buildTabSelector(),
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? _buildEstadisticasGenerales()
                        : _buildGraficos(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Construye la barra de aplicación personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00f5ff), Color(0xFF0066ff)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        'Mis Estadísticas',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: _compartirEstadisticas,
        ),
      ],
    );
  }

  /// Construye el selector de pestañas
  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton('General', 0, Icons.assessment),
          ),
          Expanded(
            child: _buildTabButton('Gráficos', 1, Icons.bar_chart),
          ),
        ],
      ),
    );
  }

  /// Construye un botón de pestaña
  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
        if (index == 1) {
          _chartAnimationController.reset();
          _chartAnimationController.forward();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00f5ff) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF00f5ff), Color(0xFF0066ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          //
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildResumenItem('Partidos', '${_estadisticasTemporada['partidos_jugados']}'),
              _buildResumenItem('Goles', '${_estadisticasTemporada['goles']}'),
              _buildResumenItem('Asistencias', '${_estadisticasTemporada['asistencias']}'),
              _buildResumenItem('Entrenamientos', '${_estadisticasTemporada['entrenamientos'] ?? 12}'),
            ],
          ),

  // Tarjeta pequeña para cada item del resumen
          //
        ],
      ),
    );
  }

  /// Construye un elemento del resumen
  Widget _buildResumenItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  /// Construye la grilla de estadísticas detalladas
  Widget _buildEstadisticasGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildEstadisticaCard(
          'Efectividad',
          '${((_estadisticasTemporada['partidos_ganados'] / _estadisticasTemporada['partidos_jugados']) * 100).toStringAsFixed(1)}%',
          Icons.trending_up,
          Colors.green,
        ),
        _buildEstadisticaCard(
          'Gol/Partido',
          '${(_estadisticasTemporada['goles'] / _estadisticasTemporada['partidos_jugados']).toStringAsFixed(2)}',
          Icons.sports_soccer,
          Colors.orange,
        ),
        _buildEstadisticaCard(
          'Minutos',
          '${_estadisticasTemporada['minutos_jugados']}\'',
          Icons.access_time,
          Colors.blue,
        ),
        _buildEstadisticaCard(
          'Min/Partido',
          '${(_estadisticasTemporada['minutos_jugados'] / _estadisticasTemporada['partidos_jugados']).toStringAsFixed(0)}\'',
          Icons.timer,
          Colors.purple,
        ),
      ],
    );
  }

  /// Construye una tarjeta de estadística individual
  Widget _buildEstadisticaCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
    final percentage = (value / total * 100).toInt();
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
        const SizedBox(height: 6),
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            widthFactor: percentage / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 9,
            color: Colors.grey[500],
          ),
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
                  Icons.credit_card,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDisciplinaItem(
                  'T. Rojas',
                  _estadisticasTemporada['tarjetas_rojas'],
                  Colors.red,
                  Icons.credit_card,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de disciplina
  Widget _buildDisciplinaItem(String label, int value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: color, size: 18),
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

  /// Construye la vista de gráficos
  Widget _buildGraficos() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGraficoBarras(),
          const SizedBox(height: 20),
          _buildGraficoCircular(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Construye el gráfico de barras mensual
  Widget _buildGraficoBarras() {
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
            'Rendimiento Mensual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return SizedBox(
                height: 180,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: _estadisticasMensuales.map((data) {
                    final maxGoles = _estadisticasMensuales
                        .map((e) => e['goles'] as int)
                        .reduce(math.max);
                    final height = maxGoles > 0 
                        ? (data['goles'] / maxGoles) * 130 * _chartAnimation.value
                        : 0.0;
                    
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: height,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00f5ff), Color(0xFF0066ff)],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            const SizedBox(height: 6),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                data['mes'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${data['goles']}',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF00f5ff),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text(
            'Goles por mes',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el gráfico circular de rendimiento
  Widget _buildGraficoCircular() {
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
            'Distribución de Resultados',
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
                flex: 2,
                child: AnimatedBuilder(
                  animation: _chartAnimation,
                  builder: (context, child) {
                    return SizedBox(
                      height: 120,
                      child: CustomPaint(
                        painter: CircularChartPainter(
                          ganados: _estadisticasTemporada['partidos_ganados'],
                          empatados: _estadisticasTemporada['partidos_empatados'],
                          perdidos: _estadisticasTemporada['partidos_perdidos'],
                          animationValue: _chartAnimation.value,
                        ),
                        child: Container(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeyendaItem('Ganados', Colors.green, _estadisticasTemporada['partidos_ganados']),
                    const SizedBox(height: 6),
                    _buildLeyendaItem('Empatados', Colors.orange, _estadisticasTemporada['partidos_empatados']),
                    const SizedBox(height: 6),
                    _buildLeyendaItem('Perdidos', Colors.red, _estadisticasTemporada['partidos_perdidos']),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de leyenda
  Widget _buildLeyendaItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
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
}

/// Painter personalizado para el gráfico circular
class CircularChartPainter extends CustomPainter {
  final int ganados;
  final int empatados;
  final int perdidos;
  final double animationValue;

  CircularChartPainter({
    required this.ganados,
    required this.empatados,
    required this.perdidos,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    
    final total = ganados + empatados + perdidos;
    if (total == 0) return;

    final ganadosAngle = (ganados / total) * 2 * math.pi * animationValue;
    final empatadosAngle = (empatados / total) * 2 * math.pi * animationValue;
    final perdidosAngle = (perdidos / total) * 2 * math.pi * animationValue;

    // Pintar ganados
    final ganadosPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      ganadosAngle,
      true,
      ganadosPaint,
    );

    // Pintar empatados
    final empatadosPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + ganadosAngle,
      empatadosAngle,
      true,
      empatadosPaint,
    );

    // Pintar perdidos
    final perdidosPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2 + ganadosAngle + empatadosAngle,
      perdidosAngle,
      true,
      perdidosPaint,
    );

    // Círculo interior blanco
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.6, innerPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
