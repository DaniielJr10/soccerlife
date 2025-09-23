import 'package:flutter/material.dart';

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
  /// 0: Inicio, 1: Estadísticas, 2: Partidos, 3: Entrenamientos, 4: Perfil
  int _selectedIndex = 0;

  // ===== MÉTODO PRINCIPAL DE CONSTRUCCIÓN =====
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo gris claro para toda la aplicación
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        // Mostrar contenido según la pestaña seleccionada
        child: _selectedIndex == 0 ? _buildHomeTab() : _buildOtherTabs(),
      ),
      // Barra de navegación inferior personalizada
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // ===== CONSTRUCCIÓN DE LA PESTAÑA PRINCIPAL (INICIO) =====
  
  /// Construye la pestaña de inicio con scroll personalizado
  /// Incluye: AppBar, tarjeta de bienvenida, estadísticas, funciones y actividad
  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // AppBar expansivo con gradiente
        _buildAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjeta de bienvenida del usuario
                _buildWelcomeCard(),
                const SizedBox(height: 20),
                
                // Estadísticas rápidas (goles, asistencias, partidos)
                _buildQuickStats(),
                const SizedBox(height: 20),
                
                // Grid de funciones principales
                _buildMainFeatures(),
                const SizedBox(height: 20),
                
                // Lista de actividad reciente
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ===== CONSTRUCCIÓN DEL APPBAR PERSONALIZADO =====
  
  /// Crea un AppBar expansivo con gradiente verde y acciones
  /// Incluye: título, fondo con gradiente, botones de notificaciones y perfil
  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true, // Mantiene el AppBar visible al hacer scroll
      backgroundColor: Colors.green[600],
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Soccer Life',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        // Fondo con gradiente verde
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green[400]!,
                Colors.green[600]!,
                Colors.green[800]!,
              ],
            ),
          ),
        ),
      ),
      // Botones de acción en la parte superior derecha
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () {
            // TODO: Implementar pantalla de notificaciones
          },
        ),
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () {
            // TODO: Implementar pantalla de perfil
          },
        ),
      ],
    );
  }

  // ===== CONSTRUCCIÓN DE LA TARJETA DE BIENVENIDA =====
  
  /// Crea una tarjeta atractiva de bienvenida con gradiente azul
  /// Incluye: avatar, mensaje de bienvenida e indicador de nivel
  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar del usuario con ícono de fútbol
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.sports_soccer,
                  color: Colors.blue,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              
              // Mensajes de bienvenida
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¡Bienvenido de vuelta!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Continúa tu viaje futbolístico',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Indicador de nivel del jugador
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Nivel Pro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE ESTADÍSTICAS RÁPIDAS =====
  
  /// Crea la sección de estadísticas rápidas con tres tarjetas
  /// Muestra: Goles, Asistencias y Partidos jugados
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Fila con las tres tarjetas de estadísticas
        Row(
          children: [
            Expanded(child: _buildStatCard('Goles', '24', Colors.orange, Icons.sports_soccer)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Asistencias', '18', Colors.purple, Icons.assist_walker)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Partidos', '32', Colors.teal, Icons.sports)),
          ],
        ),
      ],
    );
  }

  /// Construye una tarjeta individual de estadística
  /// [title] - Título de la estadística (ej: "Goles")
  /// [value] - Valor numérico a mostrar (ej: "24")
  /// [color] - Color del ícono y valor
  /// [icon] - Ícono representativo de la estadística
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // Sombra sutil para elevar la tarjeta
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
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
          
          // Valor numérico destacado
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          // Título descriptivo
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Grid de 2x2 con las funciones principales
        GridView.count(
          shrinkWrap: true, // Para que no ocupe más espacio del necesario
          physics: const NeverScrollableScrollPhysics(), // Deshabilitar scroll propio
          crossAxisCount: 2, // 2 columnas
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2, // Proporción ancho/alto de cada tarjeta
          children: [
            _buildFeatureCard(
              'Entrenamientos',
              'Registra y programa tus sesiones',
              Icons.fitness_center,
              Colors.green,
              () {
                // TODO: Navegar a pantalla de entrenamientos
              },
            ),
            _buildFeatureCard(
              'Partidos',
              'Gestiona tu calendario de juegos',
              Icons.sports_soccer,
              Colors.blue,
              () {
                // TODO: Navegar a pantalla de partidos
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          // Sombra para efecto de elevación
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor del ícono con fondo coloreado
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            
            // Título de la función
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            
            // Descripción de la función
            Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE ACTIVIDAD RECIENTE =====
  
  /// Crea la sección de actividad reciente del usuario
  /// Muestra las últimas acciones realizadas en la aplicación
  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado con título y botón "Ver todo"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navegar a pantalla completa de actividades
              },
              child: const Text('Ver todo'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Contenedor de actividades con fondo blanco
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Lista de actividades recientes
              _buildActivityItem(
                'Entrenamiento completado',
                'Hace 2 horas',
                Icons.check_circle,
                Colors.green,
              ),
              _buildActivityItem(
                'Gol anotado en el partido',
                'Ayer',
                Icons.sports_soccer,
                Colors.orange,
              ),
              _buildActivityItem(
                'Nueva meta establecida',
                'Hace 3 días',
                Icons.flag,
                Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye un elemento individual de actividad
  /// [title] - Título descriptivo de la actividad
  /// [time] - Tiempo transcurrido desde la actividad
  /// [icon] - Ícono representativo de la actividad
  /// [color] - Color del ícono
  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Contenedor del ícono con fondo coloreado
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          
          // Información de la actividad
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la actividad
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                // Tiempo de la actividad
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE OTRAS PESTAÑAS =====
  
  /// Construye el contenido para pestañas aún no implementadas
  /// Muestra un mensaje indicando que están en desarrollo
  Widget _buildOtherTabs() {
    final List<String> tabNames = ['Estadísticas', 'Partidos', 'Entrenamientos', 'Perfil'];
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ícono de construcción
          Icon(
            Icons.construction,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          
          // Título indicando desarrollo
          Text(
            '${tabNames[_selectedIndex - 1]} - En desarrollo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          
          // Mensaje descriptivo
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

  // ===== CONSTRUCCIÓN DE BARRA DE NAVEGACIÓN INFERIOR =====
  
  /// Construye la barra de navegación inferior con 5 pestañas
  /// Incluye: Inicio, Estadísticas, Partidos, Entrenamientos, Perfil
  Widget _buildBottomNavigationBar() {
    return Container(
      // Sombra superior para separar la barra del contenido
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
        
        // Configuración visual de la barra
        type: BottomNavigationBarType.fixed, // Para mostrar todas las pestañas
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green[600], // Color para pestaña seleccionada
        unselectedItemColor: Colors.grey[400], // Color para pestañas no seleccionadas
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        
        // Definición de las pestañas
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Estadísticas',
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
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
