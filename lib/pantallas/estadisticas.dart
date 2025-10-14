import 'package:flutter/material.dart';

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


// Pantalla principal de estadísticas con dashboard interactivo
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage>
    with TickerProviderStateMixin {
  
  late AnimationController _mainAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _progressAnimation;


  
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
  

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainAnimationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeInOutCubic,
    ));
    
    _mainAnimationController.forward();
    
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
                      // ...eliminado _buildRatingGeneral()...
                      _buildEstadisticasPrincipales(),
                      const SizedBox(height: 24),
                      _buildEstadisticasPartidos(),
                      const SizedBox(height: 24),
                      const SizedBox(height: 100),
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

  Widget _buildCustomAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Text(
        'Estadísticas',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          shadows: [
            Shadow(
              offset: const Offset(0, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
      ),
      centerTitle: true,
    );
  }


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
            index * 100.0,
          ),
        ),
      ],
    );
  }

  Widget _buildHabilidadCard(EstadisticaJugador estadistica, double delay) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
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
        LayoutBuilder(
          builder: (context, constraints) {
            // Ajustar el aspect ratio según el ancho disponible
            double aspectRatio = constraints.maxWidth < 400 ? 1.2 : 1.5;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: aspectRatio,
              children: _estadisticasPartidos.map((estadistica) {
                return _buildEstadisticaCard(estadistica);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildEstadisticaCard(EstadisticaPartido estadistica) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(12),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: estadistica.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  estadistica.icono,
                  color: estadistica.color,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                child: Text(
                  '${(estadistica.valor * _progressAnimation.value).round()}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: estadistica.color,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  estadistica.nombre,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF666666),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }


}
