import 'package:flutter/material.dart';

/// Página de perfil del usuario donde puede ver y gestionar su información personal
/// Incluye datos del jugador, configuraciones y opciones de la cuenta
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>
    with SingleTickerProviderStateMixin {
  // Controlador para manejar las animaciones de entrada de la página
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Información del usuario (en producción vendría de una base de datos o API)
  final Map<String, dynamic> _userInfo = {
    'nombre': 'Daniel Rodriguez',
    'username': '@daniel_jr10',
    'posicion': 'Delantero',
    'edad': 22,
    'equipo': 'FC Barcelona Academy',
    'nacionalidad': 'Colombia',
    'altura': '1.78m',
    'peso': '72kg',
  };

  @override
  void initState() {
    super.initState();
    // Configuramos la animación de fade-in para una entrada suave de la página
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    // Iniciamos la animación automáticamente al cargar la página
    _animationController.forward();
  }

  @override
  void dispose() {
    // Liberamos los recursos de la animación para evitar memory leaks
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Envolvemos todo en FadeTransition para el efecto de aparición suave
      body: FadeTransition(
        opacity: _fadeAnimation,
        // Usamos CustomScrollView para un AppBar colapsable más fluido
        child: CustomScrollView(
          slivers: [
            _buildCustomAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildSettingsSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Crea el AppBar personalizado con gradiente y efectos visuales
  /// Se colapsa al hacer scroll y mantiene el título visible
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
              Color(0xFF1565C0),
              Color(0xFF42A5F5),
            ],
          ),
        ),
        child: FlexibleSpaceBar(
          title: Text(
            'Mi Perfil',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 3,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
          centerTitle: true,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          // Abre el menú de configuración rápida desde la parte superior
          onPressed: () => _showSettingsMenu(context),
          tooltip: 'Configuración',
        ),
      ],
    );
  }

  /// Construye la sección principal del perfil con avatar y datos del jugador
  /// Incluye foto de perfil, información básica y chips informativos
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar del usuario con indicador de estado online
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF1565C0),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF1565C0),
                  child: Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              // Indicador verde que muestra que el usuario está activo/online
              Positioned(
                bottom: 5,
                right: 5,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nombre completo del jugador
          Text(
            _userInfo['nombre'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          const SizedBox(height: 4),
          // Username/alias del jugador
          Text(
            _userInfo['username'],
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          // Badge de posición con gradiente llamativo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _userInfo['posicion'],
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Chips informativos con los datos más relevantes del jugador
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildInfoChip(Icons.cake, '${_userInfo['edad']} años'),
              _buildInfoChip(Icons.sports_soccer, _userInfo['equipo']),
              _buildInfoChip(Icons.flag, _userInfo['nacionalidad']),
            ],
          ),
        ],
      ),
    );
  }

  /// Crea chips pequeños con información específica del jugador
  /// Cada chip tiene un ícono y texto descriptivo con diseño uniforme
  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de configuraciones y opciones de la cuenta
  /// Lista todas las funcionalidades disponibles organizadas en categorías
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Configuración',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildSettingsItem(
                icon: Icons.edit,
                title: 'Editar Perfil',
                subtitle: 'Actualiza tu información personal',
                onTap: () => _editProfile(context),
                color: const Color(0xFF3498DB),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.notifications,
                title: 'Notificaciones',
                subtitle: 'Configurar alertas y recordatorios',
                onTap: () => _openNotificationSettings(context),
                color: const Color(0xFFF39C12),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.privacy_tip,
                title: 'Privacidad',
                subtitle: 'Controla quién ve tu información',
                onTap: () => _openPrivacySettings(context),
                color: const Color(0xFF9B59B6),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Ayuda y Soporte',
                subtitle: 'Preguntas frecuentes y contacto',
                onTap: () => _openHelp(context),
                color: const Color(0xFF2ECC71),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.info,
                title: 'Acerca de',
                subtitle: 'Información de la aplicación',
                onTap: () => _showAboutDialog(context),
                color: const Color(0xFF34495E),
              ),
              _buildDivider(),
              _buildSettingsItem(
                icon: Icons.logout,
                title: 'Cerrar Sesión',
                subtitle: 'Salir de tu cuenta actual',
                onTap: () => _confirmLogout(context),
                color: const Color(0xFFE74C3C),
                isDestructive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Construye cada elemento individual de configuración
  /// Incluye ícono, título, descripción y acción específica
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Ícono con fondo de color temático para cada opción
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Contenido de texto del elemento de configuración
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? color : const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Flecha indicadora de que el elemento es clickeable
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// Crea un divisor sutil entre elementos de configuración
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[200],
      ),
    );
  }

  /// Muestra un menú emergente con configuraciones rápidas
  /// Incluye opciones como modo oscuro e idioma
  void _showSettingsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Configuración Rápida',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            // Opciones de configuración rápida accesibles
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('Modo Oscuro'),
              trailing: Switch(value: false, onChanged: (value) {}),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Idioma'),
              subtitle: const Text('Español'),
              onTap: () {},
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Funciones de manejo de acciones - Actualmente muestran placeholders
  /// En una implementación completa, estas navegarían a pantallas específicas
  
  void _editProfile(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de editar perfil en desarrollo'),
        backgroundColor: Color(0xFF3498DB),
      ),
    );
  }

  void _openNotificationSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de notificaciones en desarrollo'),
        backgroundColor: Color(0xFFF39C12),
      ),
    );
  }

  void _openPrivacySettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración de privacidad en desarrollo'),
        backgroundColor: Color(0xFF9B59B6),
      ),
    );
  }

  void _openHelp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ayuda y soporte en desarrollo'),
        backgroundColor: Color(0xFF2ECC71),
      ),
    );
  }

  /// Muestra el diálogo "Acerca de" con información de la aplicación
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Soccer Life',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.sports_soccer,
        size: 48,
        color: Color(0xFF1565C0),
      ),
      children: [
        const Text(
          'Una aplicación completa para gestionar tu carrera futbolística.\n\n'
          'Desarrollada con Flutter para brindarte la mejor experiencia.',
        ),
      ],
    );
  }

  /// Muestra diálogo de confirmación antes de cerrar sesión
  /// Importante para evitar cierres accidentales de sesión
  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Cerrar Sesión'),
        content: const Text(
          '¿Estás seguro de que quieres cerrar sesión? '
          'Tendrás que volver a iniciar sesión para acceder a tu cuenta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Ejecuta el logout después de confirmar
              _performLogout(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  /// Ejecuta el logout y navega de vuelta al login
  /// Elimina todo el historial de navegación para seguridad
  void _performLogout(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );
  }
}