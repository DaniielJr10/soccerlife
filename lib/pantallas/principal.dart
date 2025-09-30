import 'package:flutter/material.dart';
import 'partidos/partidosjugados.dart';
import 'entrenamientos/anteriores.dart';
import 'perfil.dart';

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
      backgroundColor: Colors.grey[50],
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
          // Tarjeta de bienvenida del usuario
          _buildWelcomeCard(),
          const SizedBox(height: 16),
          // Estadísticas rápidas (goles, asistencias, partidos)
          _buildQuickStats(),
          const SizedBox(height: 16),
          // Grid de funciones principales
          _buildMainFeatures(),
          // Eliminado: Actividad reciente
        ],
      ),
    );
  }

  // ===== APPBAR ELIMINADO =====

  // ===== CONSTRUCCIÓN DE LA TARJETA DE BIENVENIDA =====
  
  /// Crea una tarjeta atractiva de bienvenida con gradiente azul
  /// Incluye: avatar, mensaje de bienvenida e indicador de nivel
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Gradiente azul para destacar la tarjeta
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        // Sombra para dar profundidad
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar del usuario con ícono de fútbol
          const CircleAvatar(
            radius: 22,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.sports_soccer,
              color: Colors.blue,
              size: 26,
            ),
          ),
          const SizedBox(width: 12),
          
          // Mensajes de bienvenida
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Bienvenido Daniel Jr',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Continúa tu viaje futbolístico',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE ESTADÍSTICAS RÁPIDAS =====
  
  /// Crea la sección de estadísticas rápidas con cuatro tarjetas premium en un grid 2x2
  /// Muestra: Partidos, Goles, Asistencias y Entrenamientos
  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        const Text(
          'Estadísticas Rápidas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
            letterSpacing: 0.5,
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
              color: const Color(0xFF00C6AE),
              icon: Icons.sports,
              gradient: const LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildPremiumStatCard(
              title: 'Goles',
              value: '24',
              color: const Color(0xFFFFA726),
              icon: Icons.sports_soccer,
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD200), Color(0xFFFFA800)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildPremiumStatCard(
              title: 'Asistencias',
              value: '18',
              color: const Color(0xFF7C4DFF),
              icon: Icons.assist_walker,
              gradient: const LinearGradient(
                colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            _buildPremiumStatCard(
              title: 'Entrenamientos',
              value: '15',
              color: const Color(0xFF00BFAE),
              icon: Icons.fitness_center,
              gradient: const LinearGradient(
                colors: [Color(0xFF00BFAE), Color(0xFF1DE9B6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
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
    required LinearGradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
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


  // ===== CONSTRUCCIÓN DE FUNCIONES PRINCIPALES =====
  
  /// Crea el grid de funciones principales de la aplicación
  /// Incluye: Entrenamientos, Partidos, Estadísticas y Objetivos
  Widget _buildMainFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        const Text(
          'Funciones Principales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        
        // Grid de 2x2 con las funciones principales
        GridView.count(
          shrinkWrap: true, // Para que no ocupe más espacio del necesario
          physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll propio
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.3, // Proporción ancho/alto de cada tarjeta
          children: [
            _buildFeatureCard(
              'Entrenamientos',
              'Registra y programa tus sesiones',
              Icons.fitness_center,
              Colors.green,
              () {
                setState(() => _selectedIndex = 2);
              },
            ),
            _buildFeatureCard(
              'Partidos',
              'Gestiona tu calendario de juegos',
              Icons.sports_soccer,
              Colors.blue,
              () {
                setState(() => _selectedIndex = 1);
              },
            ),
            _buildFeatureCard(
              'Estadísticas',
              'Analiza tu rendimiento',
              Icons.analytics,
              Colors.purple,
              () {
                // TODO: Navegar a pantalla de estadísticas
              },
            ),
            _buildFeatureCard(
              'Objetivos',
              'Establece y sigue tus metas',
              Icons.flag,
              Colors.orange,
              () {
                // TODO: Navegar a pantalla de objetivos
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una tarjeta de función principal clickeable
  /// [title] - Título de la función (ej: "Entrenamientos")
  /// [description] - Descripción breve de la función
  /// [icon] - Ícono representativo
  /// [color] - Color del tema de la tarjeta
  /// [onTap] - Función a ejecutar al tocar la tarjeta
  Widget _buildFeatureCard(String title, String description, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Sombra para efecto de elevación
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor del ícono con fondo coloreado
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            
            // Título de la función
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            
            // Descripción de la función
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
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
