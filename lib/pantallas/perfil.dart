import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
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

  // Preferencias de notificaciones
  bool _notificacionesActivas = true;

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
    final notif = await StorageService.obtener('notificaciones_activas');

    // 1. Intentar cargar foto desde caché local
    File? foto;
    final cachedPath = await StorageService.obtenerFotoPerfil();
    if (cachedPath != null && File(cachedPath).existsSync()) {
      foto = File(cachedPath);
    } else {
      // 2. Si no hay caché, bajar del servidor
      foto = await _descargarYCacharFoto();
    }

    if (mounted) {
      setState(() {
        _usuario = usuario;
        _profileImage = foto;
        _notificacionesActivas = notif != 'false';
      });
    }
  }

  /// Descarga la foto desde MongoDB, la guarda como archivo y devuelve el File.
  Future<File?> _descargarYCacharFoto() async {
    try {
      final base64str = await AuthService.obtenerFotoPerfilServidor();
      if (base64str == null) return null;

      // Extraer datos puros (quitar prefijo data:image/...;base64,)
      final commaIdx = base64str.indexOf(',');
      final pureBase64 = commaIdx >= 0 ? base64str.substring(commaIdx + 1) : base64str;
      final bytes = base64Decode(pureBase64);

      final appDir = await getApplicationDocumentsDirectory();
      final path = '${appDir.path}/profile_cached.jpg';
      final file = await File(path).writeAsBytes(bytes);
      await StorageService.guardarFotoPerfil(file.path);
      return file;
    } catch (e) {
      return null;
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

      if (image == null) return;

      // Leer bytes y convertir a base64 con prefijo
      final bytes = await File(image.path).readAsBytes();
      final base64str = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      // Subir al servidor
      final resultado = await AuthService.subirFotoPerfil(base64str);

      if (!resultado['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resultado['message'] ?? 'Error al subir la foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Guardar localmente como caché
      final appDir = await getApplicationDocumentsDirectory();
      // Eliminar caché anterior
      final oldPath = await StorageService.obtenerFotoPerfil();
      if (oldPath != null) {
        final old = File(oldPath);
        if (old.existsSync()) old.deleteSync();
      }
      final newFile = await File(image.path).copy('${appDir.path}/profile_cached.jpg');
      await StorageService.guardarFotoPerfil(newFile.path);

      setState(() => _profileImage = newFile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Color(0xFF00f5ff),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al seleccionar imagen'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                onTap: () async {
                  Navigator.pop(context);
                  // Eliminar en servidor
                  await AuthService.eliminarFotoPerfilServidor();
                  // Eliminar caché local
                  final path = await StorageService.obtenerFotoPerfil();
                  if (path != null) {
                    final f = File(path);
                    if (f.existsSync()) f.deleteSync();
                    await StorageService.eliminarFotoPerfil();
                  }
                  setState(() => _profileImage = null);
                  if (mounted) {
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      const SnackBar(
                        content: Text('Foto de perfil eliminada'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
            color: const Color(0xFF00f5ff).withValues(alpha: 0.3),
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
            color: color.withValues(alpha: 0.1),
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
              color: color.withValues(alpha: 0.1),
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
  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Sección Configuración ──────────────────────────────────────────
        const Text(
          'Configuración',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        const SizedBox(height: 12),
        _buildSettingsCard([
          _buildSettingsItem(
            icon: Icons.edit,
            title: 'Editar Perfil',
            subtitle: 'Actualiza tu información personal',
            onTap: () => _editProfile(context),
            color: const Color(0xFF3498DB),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.lock_outline,
            title: 'Cambiar Contraseña',
            subtitle: 'Actualiza tu contraseña de acceso',
            onTap: _mostrarCambiarPassword,
            color: const Color(0xFF8E44AD),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: _notificacionesActivas ? 'Activadas' : 'Desactivadas',
            onTap: _toggleNotificaciones,
            color: const Color(0xFFF39C12),
            trailing: Switch(
              value: _notificacionesActivas,
              onChanged: (_) => _toggleNotificaciones(),
              activeThumbColor: Colors.white,
              activeTrackColor: const Color(0xFF00f5ff),
            ),
          ),
        ]),

        const SizedBox(height: 24),

        // ── Sección Soporte ────────────────────────────────────────────────
        const Text(
          'Soporte',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        const SizedBox(height: 12),
        _buildSettingsCard([
          _buildSettingsItem(
            icon: Icons.help_outline,
            title: 'Ayuda y Soporte',
            subtitle: 'Preguntas frecuentes y contacto',
            onTap: _mostrarAyuda,
            color: const Color(0xFF2ECC71),
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.info_outline,
            title: 'Acerca de',
            subtitle: 'Soccer Life · Versión 1.0.0',
            onTap: () => _showAboutDialog(context),
            color: const Color(0xFF34495E),
          ),
        ]),

        const SizedBox(height: 24),

        // ── Sección Cuenta ─────────────────────────────────────────────────
        const Text(
          'Cuenta',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
        ),
        const SizedBox(height: 12),
        _buildSettingsCard([
          _buildSettingsItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de tu cuenta actual',
            onTap: () => _confirmLogout(context),
            color: const Color(0xFFE74C3C),
            isDestructive: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            icon: Icons.delete_forever_outlined,
            title: 'Borrar Cuenta',
            subtitle: 'Eliminar permanentemente tu cuenta',
            onTap: _confirmarBorrarCuenta,
            color: const Color(0xFFC0392B),
            isDestructive: true,
          ),
        ]),
      ],
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  /// Construye cada elemento individual de configuración
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color color,
    bool isDestructive = false,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
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
                  Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                ],
              ),
            ),
            trailing ?? Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  // ── Acciones de configuración ─────────────────────────────────────────────

  void _toggleNotificaciones() async {
    final nuevo = !_notificacionesActivas;
    setState(() => _notificacionesActivas = nuevo);
    await StorageService.guardar('notificaciones_activas', nuevo.toString());
  }

  void _mostrarCambiarPassword() {
    final actCtrl = TextEditingController();
    final nuevaCtrl = TextEditingController();
    final confCtrl = TextEditingController();
    bool cargando = false;
    bool verAct = false, verNueva = false, verConf = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.lock_outline, color: Color(0xFF8E44AD)),
            SizedBox(width: 8),
            Text('Cambiar Contraseña'),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: actCtrl,
                obscureText: !verAct,
                decoration: InputDecoration(
                  labelText: 'Contraseña actual',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(verAct ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlg(() => verAct = !verAct),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nuevaCtrl,
                obscureText: !verNueva,
                decoration: InputDecoration(
                  labelText: 'Nueva contraseña',
                  border: const OutlineInputBorder(),
                  helperText: 'Mínimo 8 caracteres',
                  suffixIcon: IconButton(
                    icon: Icon(verNueva ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlg(() => verNueva = !verNueva),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confCtrl,
                obscureText: !verConf,
                decoration: InputDecoration(
                  labelText: 'Confirmar nueva contraseña',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(verConf ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setDlg(() => verConf = !verConf),
                  ),
                ),
              ),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: cargando
                  ? null
                  : () async {
                      if (actCtrl.text.isEmpty || nuevaCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Completa todos los campos'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      if (nuevaCtrl.text != confCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.orange),
                        );
                        return;
                      }
                      setDlg(() => cargando = true);
                      final res = await AuthService.cambiarPassword(
                        actual: actCtrl.text.trim(),
                        nueva: nuevaCtrl.text.trim(),
                      );
                      setDlg(() => cargando = false);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res['success'] ? '¡Contraseña actualizada!' : (res['message'] ?? 'Error')),
                          backgroundColor: res['success'] ? const Color(0xFF2ECC71) : Colors.red,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8E44AD), foregroundColor: Colors.white),
              child: cargando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarAyuda() {
    final faqs = [
      {'q': '¿Cómo registro un partido?', 'a': 'Ve a la pantalla "Partidos" y toca el botón "+" para registrar un nuevo partido con sus estadísticas.'},
      {'q': '¿Cómo se calculan mis estadísticas?', 'a': 'Las estadísticas se recalculan automáticamente cada vez que registras, editas o eliminas un partido.'},
      {'q': '¿Puedo usar la app en otro dispositivo?', 'a': 'Sí. Tus datos se sincronizan con el servidor. Solo inicia sesión con tu cuenta y todo estará disponible.'},
      {'q': '¿Cómo cambio mi foto de perfil?', 'a': 'Toca tu avatar en la pantalla de Perfil, selecciona "Elegir de galería" y elige tu foto.'},
      {'q': '¿Qué pasa si elimino mi cuenta?', 'a': 'Tu cuenta quedará inactiva y no podrás acceder. Para reactivarla, contacta al soporte.'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                Icon(Icons.help_outline, color: Color(0xFF2ECC71), size: 28),
                SizedBox(width: 10),
                Text('Ayuda y Soporte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(controller: ctrl, padding: const EdgeInsets.all(16), children: [
                ...faqs.map((f) => ExpansionTile(
                  title: Text(f['q']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  iconColor: const Color(0xFF2ECC71),
                  collapsedIconColor: Colors.grey,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(f['a']!, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    ),
                  ],
                )),
                const Divider(height: 32),
                const Text('¿Necesitas más ayuda?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                const Text('Contáctanos en:', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.email_outlined, color: Color(0xFF2ECC71), size: 20),
                  const SizedBox(width: 8),
                  const Text('soporte@soccerlife.app', style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w500)),
                ]),
                const SizedBox(height: 20),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  void _confirmarBorrarCuenta() {
    final passCtrl = TextEditingController();
    bool cargando = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlg) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.delete_forever, color: Color(0xFFC0392B)),
            SizedBox(width: 8),
            Text('Borrar Cuenta', style: TextStyle(color: Color(0xFFC0392B))),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              '⚠️ Esta acción es irreversible. Se eliminarán todos tus datos.\n\nEscribe tu contraseña para confirmar:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ]),
          actions: [
            TextButton(
              onPressed: cargando ? null : () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: cargando
                  ? null
                  : () async {
                      if (passCtrl.text.isEmpty) return;
                      setDlg(() => cargando = true);
                      // Verificar contraseña haciendo login
                      final email = _usuario.email;
                      final loginRes = await AuthService.login(email: email, password: passCtrl.text.trim());
                      if (!loginRes['success']) {
                        setDlg(() => cargando = false);
                        if (!ctx.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Contraseña incorrecta'), backgroundColor: Colors.red),
                        );
                        return;
                      }
                      final res = await AuthService.eliminarCuenta();
                      setDlg(() => cargando = false);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      if (res['success']) {
                        if (mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res['message'] ?? 'Error'), backgroundColor: Colors.red),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFC0392B), foregroundColor: Colors.white),
              child: cargando
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Borrar cuenta'),
            ),
          ],
        ),
      ),
    );
  }


  /// Funciones de manejo de acciones
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
  void _performLogout(BuildContext context) async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }
}