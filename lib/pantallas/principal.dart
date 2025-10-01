import 'package:flutter/material.dart';
import 'dart:ui';
import 'partidos/partidosjugados.dart';
import 'partidos/partidosfuturos.dart';
import 'entrenamientos/anteriores.dart';
import 'entrenamientos/proximos.dart';
import 'perfil.dart';

/// Modelo simple para partido próximo
class PartidoProximo {
  final DateTime fecha;
  final String equipoRival;
  final String lugar;
  final TimeOfDay hora;

  PartidoProximo({
    required this.fecha,
    required this.equipoRival,
    required this.lugar,
    required this.hora,
  });
}

/// Modelo simple para entrenamiento próximo
class EntrenamientoProximo {
  final DateTime fecha;
  final String tipo;
  final String objetivos;
  final String ubicacion;

  EntrenamientoProximo({
    required this.fecha,
    required this.tipo,
    required this.objetivos,
    required this.ubicacion,
  });
}

/// Modelo para perfil del jugador
class PerfilJugador {
  final String nombre;
  final int edad;
  final String club;
  final String posicion;
  final int numero;
  final int rating;

  PerfilJugador({
    required this.nombre,
    required this.edad,
    required this.club,
    required this.posicion,
    required this.numero,
    required this.rating,
  });
}

/// Pantalla principal de Soccer Life
/// 
/// Esta pantalla contiene el dashboard principal de la aplicación donde el usuario
/// puede ver su resumen de actividades, estadísticas rápidas y acceder a las
/// principales funcionalidades de la app.
/// 
/// Características principales:
/// - Dashboard con estadísticas del jugador
/// - Navegación por pestañas (Bottom Navigation)
/// - Tarjetas de funcionalidades principales
/// - Actividad reciente del usuario
class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  // ===== VARIABLES DE ESTADO =====
  
  /// Índice de la pestaña seleccionada en el bottom navigation
  /// 0: Inicio, 1: Partidos, 2: Entrenamientos, 3: Estadísticas, 4: Perfil
  int _selectedIndex = 0;

  // ===== DATOS DE EJEMPLO =====
  
  /// Perfil del jugador
  final PerfilJugador _perfilJugador = PerfilJugador(
    nombre: 'Daniel Jr',
    edad: 22,
    club: 'FC Barcelona',
    posicion: 'Delantero',
    numero: 10,
    rating: 87,
  );
  
  /// Próximo partido programado
  final PartidoProximo _proximoPartido = PartidoProximo(
    fecha: DateTime.now().add(const Duration(days: 3)),
    equipoRival: 'Valencia CF',
    lugar: 'Estadio Santiago Bernabéu',
    hora: const TimeOfDay(hour: 16, minute: 0),
  );
  
  /// Próximo entrenamiento programado
  final EntrenamientoProximo _proximoEntrenamiento = EntrenamientoProximo(
    fecha: DateTime.now().add(const Duration(days: 2)),
    tipo: 'Técnico',
    objetivos: 'Centros y remates',
    ubicacion: 'Campo principal',
  );

  // ===== MÉTODOS PARA CONTENIDO DE TABS =====

  /// Devuelve el contenido de la pestaña seleccionada según el nuevo orden
  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const PartidosJugadosPage();
      case 2:
        return const EntrenamientosAnterioresPage();
      case 3:
        return _buildOtherTab('Estadísticas');
      case 4:
        return const PerfilPage();
      default:
        return _buildHomeTab();
    }
  }

  /// Construye el contenido para una pestaña en desarrollo
  Widget _buildOtherTab(String nombre) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.95),
            const Color(0xFF16213e).withOpacity(0.9),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF00f5ff).withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.construction,
                size: 64,
                color: const Color(0xFF00f5ff),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF00f5ff).withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta funcionalidad estará disponible pronto',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ===== MÉTODO PRINCIPAL DE CONSTRUCCIÓN =====
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Fondo con imagen del estadio
          _buildFootballBackground(),
          // Contenido con SafeArea
          SafeArea(
            child: _buildTabContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Crea el fondo de la pantalla con la imagen del estadio y un overlay oscuro
  Widget _buildFootballBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/championsfondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.6),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE LA PESTAÑA PRINCIPAL (INICIO) =====
  
  /// Construye la pestaña de inicio con scroll personalizado
  /// Incluye: AppBar, tarjeta de bienvenida, estadísticas, funciones y actividad
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0), // Simplificado el padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carta del jugador estilo FIFA
          _buildCartaJugador(),
          const SizedBox(height: 16),
          // Próximo partido y entrenamiento
          _buildProximosEventos(),
          const SizedBox(height: 16),
          // Estadísticas rápidas (goles, asistencias, partidos)
          _buildQuickStats(),
          // Padding extra para el bottom navigation
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE LA CARTA DEL JUGADOR =====
  
  /// Crea una carta de jugador estilo FIFA con información básica
  Widget _buildCartaJugador() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.3),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00f5ff).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar profesional con borde y sombra
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF00f5ff), width: 3),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1a1a2e).withOpacity(0.9),
                  const Color(0xFF16213e).withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00f5ff).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                '${_perfilJugador.rating}',
                style: const TextStyle(
                  color: Color(0xFF00f5ff),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // Información del jugador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _perfilJugador.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 4,
                        color: Colors.black87,
                      ),
                    ],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  'Edad: ${_perfilJugador.edad}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _perfilJugador.club,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'Posición: ',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _perfilJugador.posicion,
                      style: const TextStyle(
                        color: Color(0xFF00f5ff),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Número del jugador
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF00f5ff),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00f5ff).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '#${_perfilJugador.numero}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE PRÓXIMOS EVENTOS =====
  
  /// Crea la sección de próximos eventos (partido y entrenamiento)
  Widget _buildProximosEventos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximos Eventos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 4,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildProximoPartidoCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildProximoEntrenamientoCard()),
          ],
        ),
      ],
    );
  }

  /// Construye la tarjeta del próximo partido
  Widget _buildProximoPartidoCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PartidosFuturosPage()),
        );
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1a2332).withOpacity(0.9),
              const Color(0xFF16213e).withOpacity(0.85),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00f5ff).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Partido',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Información del partido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '${_proximoPartido.equipoRival} vs ${_perfilJugador.club}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${_formatearFecha(_proximoPartido.fecha)} | ${_proximoPartido.hora.format(context)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoPartido.lugar,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye la tarjeta del próximo entrenamiento
  Widget _buildProximoEntrenamientoCard() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EntrenamientosProximosPage()),
        );
      },
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1a2332).withOpacity(0.9),
              const Color(0xFF16213e).withOpacity(0.85),
            ],
          ),
          border: Border.all(
            color: const Color(0xFF00f5ff).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con ícono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF00f5ff).withOpacity(0.3),
                        const Color(0xFF00f5ff).withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF00f5ff),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Entrenamiento',
                    style: TextStyle(
                      color: const Color(0xFF00f5ff).withOpacity(0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10),
            
            // Información del entrenamiento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _proximoEntrenamiento.tipo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatearFecha(_proximoEntrenamiento.fecha),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoEntrenamiento.objetivos,
                    style: TextStyle(
                      color: const Color(0xFF00f5ff).withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _proximoEntrenamiento.ubicacion,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea una fecha para mostrar de manera amigable
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora).inDays;
    
    if (diferencia == 0) {
      return 'Hoy';
    } else if (diferencia == 1) {
      return 'Mañana';
    } else if (diferencia == 2) {
      return 'Pasado mañana';
    } else {
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${fecha.day} ${meses[fecha.month - 1]}';
    }
  }

  // ===== APPBAR ELIMINADO =====

  // ===== CONSTRUCCIÓN DE ESTADÍSTICAS RÁPIDAS =====
  
  /// Crea la sección de estadísticas rápidas con cuatro tarjetas premium en un grid 2x2
  /// Muestra: Partidos, Goles, Asistencias y Entrenamientos
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas Clave',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 0.5,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 4,
                color: Colors.black87,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            double aspectRatio = 1.2;
            if (constraints.maxWidth < 400) {
              aspectRatio = 1.0;
            } else if (constraints.maxWidth > 600) {
              aspectRatio = 1.5;
            }
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: aspectRatio,
              children: [
                _buildPremiumStatCard(
                  title: 'Partidos',
                  value: '32',
                  icon: Icons.emoji_events,
                ),
                _buildPremiumStatCard(
                  title: 'Goles',
                  value: '24',
                  icon: Icons.sports_soccer,
                ),
                _buildPremiumStatCard(
                  title: 'Asistencias',
                  value: '18',
                  icon: Icons.handshake,
                ),
                _buildPremiumStatCard(
                  title: 'Entrenamientos',
                  value: '15',
                  icon: Icons.track_changes,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Tarjeta premium para estadísticas rápidas
  Widget _buildPremiumStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1e3a5f).withOpacity(0.9),
            const Color(0xFF16213e).withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00f5ff).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF00f5ff),
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 4,
                    color: Colors.black87,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }


  // ===== ACTIVIDAD RECIENTE ELIMINADA =====

  // ...existing code...

  // ===== CONSTRUCCIÓN DE BARRA DE NAVEGACIÓN INFERIOR =====
  
  /// Construye la barra de navegación inferior con diseño moderno y oscuro
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1a1a2e).withOpacity(0.98),
            const Color(0xFF16213e).withOpacity(0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00f5ff).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00f5ff),
        unselectedItemColor: Colors.white.withOpacity(0.5),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer_outlined),
            activeIcon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Entrenamientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
