import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'editarperfil.dart';
import '../models/usuario_model.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';

/// Página de perfil del usuario donde puede ver y gestionar su información personal
/// Incluye datos del jugador, configuraciones y opciones de la cuenta
class PerfilPage extends StatefulWidget {
  final Function(Map<String, dynamic>)? onPerfilActualizado;
  
  const PerfilPage({super.key, this.onPerfilActualizado});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage>
    with SingleTickerProviderStateMixin {
  // Controlador para manejar las animaciones de entrada de la página
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Para manejar la imagen del perfil
  File? _profileImage;
  final ImagePicker _picker = ImagePicker();

  // Información del usuario cargada desde el almacenamiento local
  UsuarioModel _usuario = UsuarioModel.vacio();

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
    // Cargamos los datos reales del usuario
    _cargarDatosUsuario();
  }

  /// Carga los datos del usuario desde el almacenamiento local
  Future<void> _cargarDatosUsuario() async {
    final usuario = await StorageService.obtenerUsuarioModel();
    if (mounted) {
      setState(() {
        _usuario = usuario;
      });
    }
  }

  @override
  void dispose() {
    // Liberamos los recursos de la animación para evitar memory leaks
    _animationController.dispose();
    super.dispose();
  }

  /// Función para seleccionar imagen del perfil
  Future<void> _selectProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImage = File(image.path);
        });
        
        // Mostrar mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Color(0xFF00f5ff),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Manejar errores
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al seleccionar imagen'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Mostrar opciones para cambiar foto de perfil
  void _showImageOptions() {
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
              'Cambiar foto de perfil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00f5ff).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.photo_library, color: Color(0xFF00f5ff)),
              ),
              title: const Text('Seleccionar de galería'),
              onTap: () {
                Navigator.pop(context);
                _selectProfileImage();
              },
            ),
            if (_profileImage != null)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                title: const Text('Eliminar foto'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Foto de perfil eliminada'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: CustomScrollView(
          slivers: [
            // SliverAppBar eliminado para quitar el fondo blanco vacío superior
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
  // _buildCustomAppBar eliminado porque ya no se usa

  /// Construye la sección principal del perfil con avatar y datos del jugador
  /// Incluye foto de perfil, información básica y estadísticas profesionales
  Widget _buildProfileHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Avatar y nombre principal
            Row(
              children: [
                // Avatar del usuario con gradiente y sombra
                GestureDetector(
                  onTap: _showImageOptions,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00f5ff), Color(0xFF00d4aa)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00f5ff).withValues(alpha: 0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(3),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: CircleAvatar(
                            radius: 35,
                            backgroundColor: const Color(0xFF00f5ff),
                            backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                            child: _profileImage == null
                                ? Text(
                                    _usuario.iniciales,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      // Indicador de cámara para editar
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF00f5ff),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                // Información principal del jugador
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _usuario.nombre,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1a1a2e),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _usuario.email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF1a1a2e),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Campo de posición bajado
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00f5ff), Color(0xFF00d4aa)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.sports_soccer, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Posición',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00f5ff),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _usuario.posicion,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00f5ff),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Estadísticas del jugador en tarjetas
            Row(
              children: [
                Expanded(child: _buildStatCard('Edad', _usuario.edad > 0 ? '${_usuario.edad} años' : '-', Icons.cake_outlined, const Color(0xFFf093fb), cardColor: Color(0xFF1a1a2e))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Altura', _usuario.estatura > 0 ? '${(_usuario.estatura / 100).toStringAsFixed(2)}m' : '-', Icons.height_outlined, const Color(0xFF4facfe), cardColor: Color(0xFF1a1a2e))),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Peso', _usuario.peso > 0 ? '${_usuario.peso}kg' : '-', Icons.monitor_weight_outlined, const Color(0xFF43e97b), cardColor: Color(0xFF1a1a2e))),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Club actual
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Club Actual',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF00f5ff),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _usuario.club,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00f5ff),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye una tarjeta de estadística individual
  Widget _buildStatCard(String label, String value, IconData icon, Color color, {Color cardColor = Colors.white}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cardColor == const Color(0xFF1a1a2e) ? Colors.grey[800]! : Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00f5ff),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF00f5ff),
              fontWeight: FontWeight.bold,
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

  

  /// Funciones de manejo de acciones - Actualmente muestran placeholders
  /// En una implementación completa, estas navegarían a pantallas específicas
  
  void _editProfile(BuildContext context) async {
    final initialData = {
      'nombre': _usuario.nombre,
      'posicion': _usuario.posicion,
      'edad': _usuario.edad,
      'club': _usuario.club,
      'altura': _usuario.estatura > 0 ? _usuario.estatura / 100 : null,
      'peso': _usuario.peso > 0 ? _usuario.peso : null,
    };

    final updatedData = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (context) => EditarPerfilPage(initialData: initialData),
      ),
    );

    // Si se devolvieron datos actualizados, actualizar el modelo del usuario
    if (updatedData != null) {
      // 'altura' viene como "1.80m", la BD la guarda en cm
      final estaturaMetros = double.tryParse(
            (updatedData['altura']?.toString() ?? '').replaceAll('m', ''),
          ) ?? 0.0;
      final estaturaEnCm = estaturaMetros > 0 ? estaturaMetros * 100 : _usuario.estatura;
      final nuevoPeso = int.tryParse(
            (updatedData['peso']?.toString() ?? '').replaceAll('kg', ''),
          ) ?? _usuario.peso;

      final nuevoUsuario = UsuarioModel(
        nombre: updatedData['nombre'] ?? _usuario.nombre,
        email: _usuario.email,
        posicion: updatedData['posicion'] ?? _usuario.posicion,
        club: updatedData['equipo'] ?? _usuario.club,
        edad: int.tryParse(updatedData['edad']?.toString() ?? '') ?? _usuario.edad,
        estatura: estaturaEnCm,
        peso: nuevoPeso,
      );

      // Persistir en la base de datos
      final userId = await StorageService.obtenerUserId() ?? '';
      if (userId.isNotEmpty) {
        final resultado = await AuthService.actualizarPerfil(
          userId: userId,
          datos: {
            'nombre': nuevoUsuario.nombre,
            'posicion': nuevoUsuario.posicion,
            'club': nuevoUsuario.club,
            'edad': nuevoUsuario.edad,
            'estatura': nuevoUsuario.estatura.round(),
            'peso': nuevoUsuario.peso,
          },
        );
        if (mounted && !resultado['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Advertencia: no se pudo guardar en servidor. ${resultado['message']}'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }

      // Guardar localmente
      await StorageService.guardarDatosUsuario(
        userId: userId,
        email: nuevoUsuario.email,
        nombre: nuevoUsuario.nombre,
      );
      await StorageService.guardarPerfilCompleto(
        posicion: nuevoUsuario.posicion,
        club: nuevoUsuario.club,
        edad: nuevoUsuario.edad,
        estatura: nuevoUsuario.estatura,
        peso: nuevoUsuario.peso,
      );
      setState(() {
        _usuario = nuevoUsuario;
      });

      // Notificar a la página principal que el perfil se actualizó
      if (widget.onPerfilActualizado != null) {
        widget.onPerfilActualizado!(updatedData);
      }
    }
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