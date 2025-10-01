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
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.construction,
                size: 64,
                color: const Color(0xFF4A90E2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              nombre,
              style: const TextStyle(
                fontSize: 24,
                color: Color(0xFF2C3E50),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'En desarrollo',
              style: TextStyle(
                fontSize: 16,
                color: const Color(0xFF7F8C8D),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Esta funcionalidad estará disponible pronto',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF7F8C8D).withOpacity(0.8),
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
      backgroundColor: const Color(0xFFF8F9FA), // Fondo claro
      body: SafeArea(
        child: _buildTabContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // El fondo visual oscuro ha sido eliminado para un tema claro
  // Si se desea un fondo claro con imagen, se puede agregar aquí una versión clara
  // pero por ahora se omite para mantener el diseño limpio y claro.

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
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
              border: Border.all(color: const Color(0xFF4A90E2), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              color: Colors.white,
            ),
            child: Center(
              child: Icon(
                Icons.person,
                color: const Color(0xFF4A90E2),
                size: 44,
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
                    color: Color(0xFF2C3E50),
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.star, color: Color(0xFFF5B041), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '${_perfilJugador.rating}',
                      style: const TextStyle(
                        color: Color(0xFF4A90E2),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Edad', '${_perfilJugador.edad}')),
                    Expanded(child: _buildInfoItem('Número', '#${_perfilJugador.numero}')),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Club', _perfilJugador.club)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(child: _buildInfoItem('Posición', _perfilJugador.posicion)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construye un elemento de información para la carta del jugador
  /// Construye un elemento de información para la carta del jugador
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
            color: Color(0xFF4A90E2),
            letterSpacing: 0.5,
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.08),
            width: 1,
          ),
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
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 16, // Reducido ligeramente
                  ),
                ),
                const SizedBox(width: 10), // Reducido
                Expanded(
                  child: Text(
                    'Partido',
                    style: TextStyle(
                      color: Color(0xFF4A90E2),
                      fontSize: 13, // Reducido
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10), // Espacio fijo
            
            // Información del partido
            Expanded( // Cambiado a Expanded para usar todo el espacio disponible
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuir uniformemente
                children: [
                  Text(
                    _proximoPartido.equipoRival,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 15, // Ligeramente reducido
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatearFecha(_proximoPartido.fecha),
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoPartido.hora.format(context),
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoPartido.lugar,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 10, // Reducido para evitar overflow
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: Colors.grey.withOpacity(0.08),
            width: 1,
          ),
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
                    color: const Color(0xFF27AE60),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Colors.white,
                    size: 16, // Reducido ligeramente
                  ),
                ),
                const SizedBox(width: 10), // Reducido
                Expanded(
                  child: Text(
                    'Entrenamiento',
                    style: TextStyle(
                      color: Color(0xFF27AE60),
                      fontSize: 13, // Reducido
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 10), // Espacio fijo
            
            // Información del entrenamiento
            Expanded( // Cambiado a Expanded para usar todo el espacio disponible
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuir uniformemente
                children: [
                  Text(
                    _proximoEntrenamiento.tipo,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontSize: 15, // Ligeramente reducido
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _formatearFecha(_proximoEntrenamiento.fecha),
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoEntrenamiento.objetivos,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _proximoEntrenamiento.ubicacion,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontSize: 10, // Reducido para evitar overflow
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
          'Estadísticas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00f5ff),
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 6,
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
                  color: const Color(0xFF00f5ff),
                  icon: Icons.sports,
                ),
                _buildPremiumStatCard(
                  title: 'Goles',
                  value: '24',
                  color: const Color(0xFFE74C3C),
                  icon: Icons.sports_soccer,
                ),
                _buildPremiumStatCard(
                  title: 'Asistencias',
                  value: '18',
                  color: const Color(0xFFF39C12),
                  icon: Icons.handshake,
                ),
                _buildPremiumStatCard(
                  title: 'Entrenamientos',
                  value: '15',
                  color: const Color(0xFF00d4aa),
                  icon: Icons.workspace_premium,
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
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.18),
          width: 1.2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
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
                color: color,
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
  
  /// Construye la barra de navegación inferior con diseño moderno y claro
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF4A90E2),
        unselectedItemColor: const Color(0xFF7F8C8D),
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
