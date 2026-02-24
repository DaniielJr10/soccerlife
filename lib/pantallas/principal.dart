import 'package:flutter/material.dart';
import 'partidos/partidosjugados.dart';
import 'partidos/partidosfuturos.dart';
import 'perfil.dart';
import 'estadisticas.dart';
import '../models/usuario_model.dart';
import '../services/storage_service.dart';
import '../services/estadisticas_service.dart';

/// Clase que representa un partido próximo a jugar
/// Contiene toda la información necesaria para mostrar el siguiente encuentro
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

/// Pantalla principal de la aplicación SoccerLife
/// Muestra el dashboard con información del jugador, próximos eventos y estadísticas
class PrincipalPage extends StatefulWidget {
  const PrincipalPage({super.key});

  @override
  State<PrincipalPage> createState() => _PrincipalPageState();
}

class _PrincipalPageState extends State<PrincipalPage> {
  // Índice del tab seleccionado en el bottom navigation bar
  int _selectedIndex = 0;

  // Datos del usuario cargados desde almacenamiento local
  UsuarioModel _usuario = UsuarioModel.vacio();

  // Estadísticas rápidas cargadas desde la API
  Map<String, int> _statsResumen = {
    'partidos': 0,
    'goles': 0,
    'asistencias': 0,
  };

  bool _cargando = true;

  // Información del próximo partido programado
  final PartidoProximo _proximoPartido = PartidoProximo(
    fecha: DateTime.now().add(const Duration(days: 3)),
    equipoRival: 'Sin partido aún',
    lugar: '- -',
    hora: const TimeOfDay(hour: 0, minute: 0),
  );

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  /// Carga los datos del usuario y las estadísticas desde almacenamiento y API
  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);
    final usuario = await StorageService.obtenerUsuarioModel();
    final resultado = await EstadisticasService.obtenerEstadisticas();
    Map<String, int> stats = {
      'partidos': 0,
      'goles': 0,
      'asistencias': 0,
    };
    if (resultado['success'] == true && resultado['estadisticas'] != null) {
      final s = resultado['estadisticas'] as Map<String, dynamic>;
      final partidos = (s['partidos'] as Map?)?.cast<String, dynamic>() ?? {};
      final goles = (s['goles'] as Map?)?.cast<String, dynamic>() ?? {};
      stats = {
        'partidos': (partidos['jugados'] ?? 0) as int,
        'goles': (goles['total'] ?? 0) as int,
        'asistencias': (s['asistencias'] ?? 0) as int,
      };
    }
    if (!mounted) return;
    setState(() {
      _usuario = usuario;
      _statsResumen = stats;
      _cargando = false;
    });
  }

  /// Actualiza los datos del perfil del jugador
  void _actualizarPerfil(Map<String, dynamic> datosActualizados) {
    setState(() {
      _usuario = UsuarioModel(
        nombre: datosActualizados['nombre']?.toString() ?? _usuario.nombre,
        email: _usuario.email,
        posicion: datosActualizados['posicion']?.toString() ?? _usuario.posicion,
        club: datosActualizados['equipo']?.toString() ?? _usuario.club,
        edad: int.tryParse(datosActualizados['edad']?.toString() ?? '') ?? _usuario.edad,
      );
    });
  }

  /// Determina qué contenido mostrar según el tab seleccionado
  /// Cada caso corresponde a una sección diferente de la app
  Widget _buildTabContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const PartidosJugadosPage();
      case 2:
        return const EstadisticasPage();
      case 3:
        return PerfilPage(onPerfilActualizado: _actualizarPerfil);
      default:
        return _buildHomeTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: SafeArea(child: _buildTabContent()),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  /// Construye la pestaña principal (Home) con el dashboard completo
  /// Incluye la carta del jugador, próximos eventos y estadísticas rápidas
  Widget _buildHomeTab() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF00f5ff)));
    }
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: 16.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCartaJugador(),
            const SizedBox(height: 24),
            _buildProximosEventos(),
            const SizedBox(height: 24),
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  /// Crea la carta principal del jugador con su información personal
  /// Diseño estilo tarjeta deportiva con gradiente azul y avatar circular
  Widget _buildCartaJugador() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF00f5ff),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0065F8).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            // Avatar circular con las iniciales del jugador
            child: Center(
              child: Text(
                _usuario.iniciales,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: Color(0xFF1a1a2e),
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _usuario.nombre.isEmpty ? 'Jugador' : _usuario.nombre,
                  style: const TextStyle(
                    color: Color(0xFF1a1a2e),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _usuario.club.isEmpty ? 'Sin club' : 'Club: ${_usuario.club}',
                            style: const TextStyle(
                              color: Color(0xFF1a1a2e),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _usuario.posicion.isEmpty ? 'Sin posición' : 'Posición: ${_usuario.posicion}',
                            style: const TextStyle(
                              color: Color(0xFF1a1a2e),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _usuario.edad == 0 ? '' : 'Edad: ${_usuario.edad} años',
                  style: const TextStyle(
                    color: Color(0xFF1a1a2e),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Sección que muestra el próximo partido del jugador
  Widget _buildProximosEventos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Próximo Partido',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a2e),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildProximoPartidoCard(),
      ],
    );
  }

  /// Tarjeta del próximo partido con navegación a la página de partidos futuros
  /// Muestra rival, lugar, fecha y hora del encuentro
  Widget _buildProximoPartidoCard() {
    return GestureDetector(
      // Al tocar la tarjeta, navega a la página de partidos futuros
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PartidosFuturosPage()),
        );
      },
      child: Container(
        height: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00f5ff),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a1a2e),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF00f5ff),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Próximo Partido',
                    style: TextStyle(
                      color: Color(0xFF1a1a2e),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    _proximoPartido.equipoRival,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1a1a2e),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _proximoPartido.lugar,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${_formatearFecha(_proximoPartido.fecha)} • ${_proximoPartido.hora.format(context)}',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Función que formatea las fechas de manera intuitiva para el usuario
  /// Convierte las fechas en texto amigable (Hoy, Mañana, etc.)
  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = fecha.difference(ahora).inDays;
    
    // Casos especiales para fechas muy próximas
    if (diferencia == 0) {
      return 'Hoy';
    } else if (diferencia == 1) {
      return 'Mañana';
    } else if (diferencia == 2) {
      return 'Pasado mañana';
    } else {
      // Para fechas más lejanas, mostrar día y mes abreviado
      final meses = [
        'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      return '${fecha.day} ${meses[fecha.month - 1]}';
    }
  }

  /// Sección de estadísticas rápidas de la temporada actual
  /// Muestra los números más importantes en un grid de 2x2
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estadísticas de la Temporada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a1a2e),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        // Grid de estadísticas con diseño 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.0,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildPremiumStatCard(
              title: 'Partidos',
              value: '${_statsResumen['partidos'] ?? 0}',
              icon: Icons.sports_esports,
            ),
            _buildPremiumStatCard(
              title: 'Goles',
              value: '${_statsResumen['goles'] ?? 0}',
              icon: Icons.sports_soccer,
            ),
            _buildPremiumStatCard(
              title: 'Asistencias',
              value: '${_statsResumen['asistencias'] ?? 0}',
              icon: Icons.handshake,
            ),
          ],
        ),
      ],
    );
  }

  /// Construye cada tarjeta individual de estadística
  /// Recibe el título, valor e ícono para crear una tarjeta uniforme
  Widget _buildPremiumStatCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    // Si la tarjeta es de 'Partidos', cambia el orden: logo, texto 'Partidos', número debajo
    // Todas las tarjetas: logo, título y debajo el número
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (title == 'Partidos' || title == 'Goles' || title == 'Asistencias')
              ? const Color(0xFF00f5ff)
              : const Color(0xFF0065F8).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0065F8).withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (title == 'Partidos' || title == 'Goles' || title == 'Asistencias')
                    ? const Color(0xFF1a1a2e)
                    : const Color(0xFF0065F8).withValues(alpha: 0.08),
              ),
              child: Icon(
                icon,
                color: (title == 'Partidos' || title == 'Goles' || title == 'Asistencias')
                    ? const Color(0xFF00f5ff)
                    : const Color(0xFF0065F8),
                size: 20,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF1a1a2e),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1a1a2e),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Crea el bottom navigation bar con gradiente y efectos visuales
  /// Maneja la navegación entre las diferentes secciones de la app
  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1a1a2e),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00f5ff).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        // Actualiza el estado cuando se selecciona un tab diferente
        onTap: (index) {
          setState(() => _selectedIndex = index);
          if (index == 0) _cargarDatos(); // refrescar estadísticas al volver al inicio
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color(0xFF00f5ff),
        unselectedItemColor: Colors.white.withValues(alpha: 0.5),
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
