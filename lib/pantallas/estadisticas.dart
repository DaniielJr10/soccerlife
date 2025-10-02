import 'package:flutter/material.dart';

/// Modelo para estadísticas del jugador
class EstadisticaJugador {
  final String categoria;
  final int valor;
  final int maximo;
  final Color color;
  final IconData icono;

  EstadisticaJugador({
    required this.categoria,
    required this.valor,
    required this.maximo,
    required this.color,
    required this.icono,
  });
}

/// Modelo para estadísticas de partidos
class EstadisticaPartido {
  final String nombre;
  final int valor;
  final IconData icono;
  final Color color;

  EstadisticaPartido({
    required this.nombre,
    required this.valor,
    required this.icono,
    required this.color,
  });
}

/// Modelo para progreso mensual
class ProgresoMensual {
  final String mes;
  final double rendimiento;

  ProgresoMensual({
    required this.mes,
    required this.rendimiento,
  });
}

/// Pantalla de estadísticas de Soccer Life
/// 
/// Esta pantalla muestra todas las estadísticas del jugador de manera visual
/// e interactiva. Incluye métricas de rendimiento, progreso en el tiempo,
/// comparaciones y análisis detallado del desempeño deportivo.
/// 
/// Características principales:
/// - Dashboard completo de estadísticas
/// - Gráficos y visualizaciones atractivas
/// - Métricas de rendimiento en tiempo real
/// - Progreso histórico del jugador
/// - Comparaciones con promedio del equipo
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage>
    with TickerProviderStateMixin {
  // ===== CONTROLADORES DE ANIMACIÓN =====
  
  /// Controlador principal para animaciones de entrada
  late AnimationController _mainAnimationController;
  
  /// Controlador para animaciones de progreso circular
  late AnimationController _progressAnimationController;
  
  /// Animación de fade-in para elementos
  late Animation<double> _fadeAnimation;
  
  /// Animación de slide-up para cards
  late Animation<Offset> _slideAnimation;
  
  /// Animación para barras de progreso
  late Animation<double> _progressAnimation;

  // ===== DATOS DE ESTADÍSTICAS =====
  
  /// Rating general del jugador
  final int _ratingGeneral = 87;
  
  /// Estadísticas principales del jugador
  final List<EstadisticaJugador> _estadisticasPrincipales = [
    EstadisticaJugador(
      categoria: 'Velocidad',
      valor: 91,
      maximo: 100,
      color: const Color(0xFF4CAF50),
      icono: Icons.speed,
    ),
    EstadisticaJugador(
      categoria: 'Precisión',
      valor: 85,
      maximo: 100,
      color: const Color(0xFF2196F3),
      icono: Icons.gps_fixed,
    ),
    EstadisticaJugador(
      categoria: 'Resistencia',
      valor: 88,
      maximo: 100,
      color: const Color(0xFFFF9800),
      icono: Icons.fitness_center,
    ),
    EstadisticaJugador(
      categoria: 'Técnica',
      valor: 92,
      maximo: 100,
      color: const Color(0xFF9C27B0),
      icono: Icons.sports_soccer,
    ),
  ];
  
  /// Estadísticas de partidos
  final List<EstadisticaPartido> _estadisticasPartidos = [
    EstadisticaPartido(
      nombre: 'Goles',
      valor: 24,
      icono: Icons.sports_soccer,
      color: const Color(0xFF4CAF50),
    ),
    EstadisticaPartido(
      nombre: 'Asistencias',
      valor: 12,
      icono: Icons.handshake,
      color: const Color(0xFF2196F3),
    ),
    EstadisticaPartido(
      nombre: 'Partidos',
      valor: 31,
      icono: Icons.calendar_today,
      color: const Color(0xFFFF9800),
    ),
    EstadisticaPartido(
      nombre: 'Minutos',
      valor: 2580,
      icono: Icons.timer,
      color: const Color(0xFF9C27B0),
    ),
  ];
  
  /// Progreso mensual del último semestre
  final List<ProgresoMensual> _progresoMensual = [
    ProgresoMensual(mes: 'May', rendimiento: 75),
    ProgresoMensual(mes: 'Jun', rendimiento: 82),
    ProgresoMensual(mes: 'Jul', rendimiento: 78),
    ProgresoMensual(mes: 'Ago', rendimiento: 85),
    ProgresoMensual(mes: 'Sep', rendimiento: 91),
    ProgresoMensual(mes: 'Oct', rendimiento: 87),
  ];

  // ===== MÉTODOS DE CICLO DE VIDA =====

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Inicializa todas las animaciones necesarias para la pantalla
  void _initializeAnimations() {
    // Controlador principal de animaciones
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    // Controlador para animaciones de progreso
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Animación de fade-in
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Animación de slide-up
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    // Animación de progreso
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    // Iniciar animaciones
    _mainAnimationController.forward();
    
    // Delay para la animación de progreso
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _progressAnimationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  // ===== MÉTODO BUILD PRINCIPAL =====

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            _buildCustomAppBar(),
            SliverToBoxAdapter(
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingGeneral(),
                      const SizedBox(height: 24),
                      _buildEstadisticasPrincipales(),
                      const SizedBox(height: 24),
                      _buildEstadisticasPartidos(),
                      const SizedBox(height: 24),
                      _buildProgresoMensual(),
                      const SizedBox(height: 24),
                      _buildComparacionEquipo(),
                      const SizedBox(height: 100), // Espacio para bottom navigation
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== MÉTODOS DE CONSTRUCCIÓN DE WIDGETS =====

  /// Construye el AppBar personalizado con gradiente
  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0065F8),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Mis Estadísticas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
    );
  }

  /// Construye el widget del rating general del jugador
  Widget _buildRatingGeneral() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0065F8),
            Color(0xFF1976D2),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0065F8).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Rating General',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de progreso de fondo
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 8,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(
                        Colors.white.withOpacity(0.2),
                      ),
                    ),
                  ),
                  // Círculo de progreso principal
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: (_ratingGeneral / 100) * _progressAnimation.value,
                      strokeWidth: 8,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  // Número del rating
                  Column(
                    children: [
                      Text(
                        '${(_ratingGeneral * _progressAnimation.value).round()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '/100',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Excelente rendimiento',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las estadísticas principales con barras de progreso animadas
  Widget _buildEstadisticasPrincipales() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Habilidades Principales',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          _estadisticasPrincipales.length,
          (index) => _buildHabilidadCard(
            _estadisticasPrincipales[index],
            index * 100.0, // Delay para cada card
          ),
        ),
      ],
    );
  }

  /// Construye una card individual de habilidad con animación
  Widget _buildHabilidadCard(EstadisticaJugador estadistica, double delay) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        // Calcular delay individual para cada card
        double cardProgress = (_progressAnimation.value * 1000 - delay).clamp(0.0, 1.0);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icono con fondo colorido
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: estadistica.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  estadistica.icono,
                  color: estadistica.color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Información y barra de progreso
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          estadistica.categoria,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        Text(
                          '${(estadistica.valor * cardProgress).round()}/${estadistica.maximo}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: estadistica.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Barra de progreso personalizada
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (estadistica.valor / estadistica.maximo) * cardProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                estadistica.color.withOpacity(0.7),
                                estadistica.color,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye las estadísticas de partidos en un grid
  Widget _buildEstadisticasPartidos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas de Temporada',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: _estadisticasPartidos.map((estadistica) {
            return _buildEstadisticaCard(estadistica);
          }).toList(),
        ),
      ],
    );
  }

  /// Construye una card individual de estadística de partido
  Widget _buildEstadisticaCard(EstadisticaPartido estadistica) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: estadistica.color.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: estadistica.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: estadistica.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  estadistica.icono,
                  color: estadistica.color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              // Valor animado
              Text(
                '${(estadistica.valor * _progressAnimation.value).round()}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: estadistica.color,
                ),
              ),
              const SizedBox(height: 4),
              // Nombre de la estadística
              Text(
                estadistica.nombre,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF666666),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construye el gráfico de progreso mensual
  Widget _buildProgresoMensual() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Progreso Mensual',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: _progresoMensual.map((progreso) {
                    return _buildBarraProgreso(progreso);
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construye una barra individual del gráfico de progreso
  Widget _buildBarraProgreso(ProgresoMensual progreso) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Valor encima de la barra
        Text(
          '${(progreso.rendimiento * _progressAnimation.value).round()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0065F8),
          ),
        ),
        const SizedBox(height: 4),
        // Barra de progreso
        Container(
          width: 24,
          height: (progreso.rendimiento / 100) * 150 * _progressAnimation.value,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Color(0xFF0065F8),
                Color(0xFF42A5F5),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        // Mes
        Text(
          progreso.mes,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF666666),
          ),
        ),
      ],
    );
  }

  /// Construye la sección de comparación con el equipo
  Widget _buildComparacionEquipo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFE3F2FD),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF0065F8).withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0065F8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF0065F8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Comparación con el Equipo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildComparacionItem('Goles por partido', 0.77, 0.65, 'Por encima del promedio'),
          const SizedBox(height: 12),
          _buildComparacionItem('Precisión de pases', 0.91, 0.83, 'Muy por encima'),
          const SizedBox(height: 12),
          _buildComparacionItem('Distancia recorrida', 0.82, 0.79, 'Ligeramente superior'),
        ],
      ),
    );
  }

  /// Construye un item individual de comparación
  Widget _buildComparacionItem(String titulo, double tuValor, double promedioEquipo, String descripcion) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Barras de comparación
            Row(
              children: [
                // Tu rendimiento
                Expanded(
                  flex: (tuValor * 100).round(),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0065F8), Color(0xFF42A5F5)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0065F8), Color(0xFF42A5F5)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (tuValor * 100).round(),
                  child: Container(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                // Promedio del equipo
                Expanded(
                  flex: (promedioEquipo * 100).round(),
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: FractionallySizedBox(
                      widthFactor: _progressAnimation.value,
                      alignment: Alignment.centerLeft,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 100 - (promedioEquipo * 100).round(),
                  child: Container(),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tu rendimiento: ${(tuValor * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF0065F8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Promedio equipo: ${(promedioEquipo * 100).round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
