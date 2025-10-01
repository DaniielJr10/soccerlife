import 'package:flutter/material.dart';
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '$nombre - En desarrollo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Esta funcionalidad estará disponible pronto',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  // ===== MÉTODO PRINCIPAL DE CONSTRUCCIÓN =====
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Fondo negro premium
      body: SafeArea(
        child: _buildTabContent(),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===== CONSTRUCCIÓN DE LA PESTAÑA PRINCIPAL (INICIO) =====
  
  /// Construye la pestaña de inicio con scroll personalizado
  /// Incluye: AppBar, tarjeta de bienvenida, estadísticas, funciones y actividad
  Widget _buildHomeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0), // Agregamos padding bottom para el BottomNavigationBar
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
          // Eliminado: Actividad reciente y Funciones principales
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE LA CARTA DEL JUGADOR =====
  
  /// Crea una carta de jugador estilo FIFA con información básica
  Widget _buildCartaJugador() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gradiente premium oscuro con dorado
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A1A), // Gris oscuro
            Color(0xFF2D2D2D), // Gris medio
            Color(0xFF1A1A1A), // Gris oscuro
          ],
        ),
        border: Border.all(
          color: const Color(0xFFFFD700),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(20),
        // Sombra premium con múltiples capas
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.8),
            blurRadius: 30,
            spreadRadius: -5,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del jugador con rating
          Stack(
            alignment: Alignment.center,
            children: [
              // Círculo del avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFD700),
                      Color(0xFFFFA500),
                      Color(0xFFFFD700),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFD700).withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFFFFD700),
                    size: 40,
                  ),
                ),
              ),
              // Badge del rating
              Positioned(
                bottom: -5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: const Color(0xFF1A1A1A), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    '${_perfilJugador.rating}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Información del jugador
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre del jugador
                Text(
                  _perfilJugador.nombre,
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                
                // Información básica en grid
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Edad', '${_perfilJugador.edad}'),
                    ),
                    Expanded(
                      child: _buildInfoItem('Número', '#${_perfilJugador.numero}'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Club', _perfilJugador.club),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem('Posición', _perfilJugador.posicion),
                    ),
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
  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFB0B0B0),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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
        // Título de la sección
        const Text(
          'Próximos Eventos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        // Row con las dos tarjetas
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
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header con ícono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF1A1A1A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Partido',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Información del partido
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _proximoPartido.equipoRival,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatearFecha(_proximoPartido.fecha),
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoPartido.hora.format(context),
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoPartido.lugar,
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 11,
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
        height: 130,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.15),
              Colors.white.withOpacity(0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.1),
              blurRadius: 1,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header con ícono
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFFFD700),
                        Color(0xFFFFA500),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color(0xFF1A1A1A),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Entrenamiento',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Información del entrenamiento
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _proximoEntrenamiento.tipo,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatearFecha(_proximoEntrenamiento.fecha),
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _proximoEntrenamiento.objetivos,
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _proximoEntrenamiento.ubicacion,
                    style: const TextStyle(
                      color: Color(0xFFB0B0B0),
                      fontSize: 11,
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
        // Título de la sección
        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                offset: Offset(0, 2),
                blurRadius: 8,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Grid de 2x2 con tarjetas premium
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.4,
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
              color: const Color(0xFF00f5ff),
              icon: Icons.sports_soccer,
            ),
            _buildPremiumStatCard(
              title: 'Asistencias',
              value: '18',
              color: const Color(0xFF00f5ff),
              icon: Icons.assist_walker,
            ),
            _buildPremiumStatCard(
              title: 'Entrenamientos',
              value: '15',
              color: const Color(0xFF00f5ff),
              icon: Icons.fitness_center,
            ),
          ],
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFFFFD700),
                  Color(0xFFFFA500),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: const Color(0xFF1A1A1A), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ===== ACTIVIDAD RECIENTE ELIMINADA =====

  // ...existing code...

  // ===== CONSTRUCCIÓN DE BARRA DE NAVEGACIÓN INFERIOR =====
  
  /// Construye la barra de navegación inferior con 5 pestañas
  /// Incluye: Inicio, Partidos, Entrenamientos, Estadísticas, Perfil
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
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
        selectedItemColor: Colors.green[600],
        unselectedItemColor: Colors.grey[400],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Partidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Entrenamientos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
