import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/storage_service.dart';
import '../../../hoja_de_vida/presentation/pages/hoja_de_vida_page.dart';
import '../../../achievements/presentation/pages/achievements_page.dart';
import '../../../profile_picture/application/profile_picture_provider.dart';
import '../../../profile_picture/presentation/pages/profile_picture_page.dart';
import '../../../profile_picture/presentation/widgets/profile_avatar_widget.dart';
import 'change_password_page.dart';
import 'edit_profile_page.dart';

/// Página de perfil del jugador.
/// Carga datos frescos desde MongoDB; usa caché local como fallback.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UsuarioModel _usuario = UsuarioModel.vacio();
  bool _cargando = true;
  String? _errorMsg;
  bool _notificacionesActivas = true;

  // Foto de perfil — se gestiona a través del ProfilePictureProvider
  bool _cargandoFoto = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _errorMsg = null; });
    final notif = await StorageService.obtener('notificaciones_activas');
    if (mounted) setState(() => _notificacionesActivas = notif != 'false');

    // Carga perfil y foto en paralelo
    await Future.wait([
      ProfileService.obtenerPerfil().then((perfilResult) async {
        if (perfilResult['success'] == true) {
          final u = perfilResult['usuario'] as Map<String, dynamic>;
          if (mounted) setState(() => _usuario = UsuarioModel.fromMap(u));
        } else {
          final cached = await StorageService.obtenerUsuarioModel();
          if (mounted) setState(() {
            _usuario = cached;
            _errorMsg = 'Sin conexión — mostrando datos locales';
          });
        }
      }),
      // Delega la carga de la foto al provider compartido
      if (mounted) context.read<ProfilePictureProvider>().load(),
    ]);

    if (mounted) setState(() { _cargando = false; _cargandoFoto = false; });
  }

  Future<void> _abrirFotoPerfil() async {
    final provider = context.read<ProfilePictureProvider>();
    final newBytes = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePicturePage(
          nombre: _usuario.nombre,
          fotoActual: provider.photoBytes,
        ),
      ),
    );
    // ProfilePicturePage devuelve los nuevos bytes (o null si se eliminó).
    // Actualizamos el provider para que Dashboard y Perfil reflejen el cambio.
    if (mounted) {
      // ignore: use_build_context_synchronously
      context.read<ProfilePictureProvider>().setPhoto(
        newBytes is List<int> ? Uint8List.fromList(newBytes) : newBytes as Uint8List?,
      );
    }
  }

  Future<void> _editarPerfil() async {
    final datos = {
      'nombre': _usuario.nombre,
      'posicion': _usuario.posicion,
      'club': _usuario.club,
      'edad': _usuario.edad,
      'estatura': _usuario.estatura,
      'peso': _usuario.peso,
    };
    final resultado = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
          builder: (_) => EditProfilePage(datosActuales: datos)),
    );
    if (resultado != null) {
      setState(() => _usuario = UsuarioModel.fromMap(resultado));
    }
  }

  Future<void> _cerrarSesion() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Cerrar sesión',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('¿Deseas cerrar tu sesión?',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Cerrar sesión',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await StorageService.limpiarDatos();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _cargar,
              color: AppColors.primary,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (_errorMsg != null) _bannerConexion(),
                  _buildAvatar(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildEditButton(),
                  const SizedBox(height: 12),
                  _buildCvButton(),
                  const SizedBox(height: 16),
                  _buildConfigCard(),
                  const SizedBox(height: 12),
                  _buildSupportCard(),
                  const SizedBox(height: 12),
                  _buildAccountCard(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _bannerConexion() => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_errorMsg!,
                  style: TextStyle(color: AppColors.warning, fontSize: 12)),
            ),
          ],
        ),
      );

  Widget _buildAvatar() {
    final photoBytes = context.watch<ProfilePictureProvider>().photoBytes;
    return Center(
      child: Column(
        children: [
          ProfileAvatarWidget(
            nombre: _usuario.nombre,
            imageBytes: _cargandoFoto ? null : photoBytes,
            radius: 52,
            showEditBadge: true,
            onTap: _abrirFotoPerfil,
          ),
          const SizedBox(height: 12),
          Text(
            _usuario.nombre.isNotEmpty ? _usuario.nombre : 'Jugador',
            style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(_usuario.email,
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),

        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return _card(
      title: 'Información personal',
      children: [
        _infoRow(Icons.person_outline, 'Nombre', _usuario.nombre),
        _infoRow(Icons.email_outlined, 'Email', _usuario.email),
        if (_usuario.posicion.isNotEmpty)
          _infoRow(Icons.sports_soccer, 'Posición', _usuario.posicion),
        if (_usuario.club.isNotEmpty)
          _infoRow(Icons.shield_outlined, 'Club', _usuario.club),
        if (_usuario.edad > 0)
          _infoRow(Icons.cake_outlined, 'Edad', '${_usuario.edad} años'),
        if (_usuario.estatura > 0)
          _infoRow(Icons.height, 'Estatura',
              '${_usuario.estatura.toStringAsFixed(0)} cm'),
        if (_usuario.peso > 0)
          _infoRow(Icons.monitor_weight_outlined, 'Peso',
              '${_usuario.peso} kg'),
      ],
    );
  }

  Widget _buildEditButton() => SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.edit_rounded),
          label: const Text('Editar perfil'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _editarPerfil,
        ),
      );

  Widget _buildCvButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.style_rounded),
          label: const Text('CV Deportivo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFD700),
            foregroundColor: const Color(0xFF2C1A00),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w800),
            elevation: 0,
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HojaDeVidaPage()),
          ),
        ),
      );

  Widget _buildConfigCard() {
    return _card(
      title: 'CONFIGURACIÓN',
      children: [
        _actionTile(
          icon: Icons.military_tech_rounded,
          label: 'Logros',
          sublabel: 'Mis medallas y logros desbloqueados',
          color: const Color(0xFF00f5ff),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AchievementsPage()),
          ),
        ),
        _divider(),
        _actionTile(
          icon: Icons.lock_outline,
          label: 'Cambiar Contraseña',
          color: const Color(0xFF8E44AD),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
          ),
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF39C12).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notifications_outlined, color: Color(0xFFF39C12), size: 20),
          ),
          title: const Text('Notificaciones', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          subtitle: Text(_notificacionesActivas ? 'Activadas' : 'Desactivadas',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          trailing: Switch(
            value: _notificacionesActivas,
            onChanged: (_) => _toggleNotificaciones(),
            activeColor: AppColors.primary,
          ),
          onTap: _toggleNotificaciones,
        ),
      ],
    );
  }

  Widget _buildSupportCard() {
    return _card(
      title: 'SOPORTE',
      children: [
        _actionTile(
          icon: Icons.help_outline,
          label: 'Ayuda y Soporte',
          color: const Color(0xFF2ECC71),
          onTap: _mostrarAyuda,
        ),
        _divider(),
        _actionTile(
          icon: Icons.info_outline,
          label: 'Acerca de',
          sublabel: 'Soccer Life · v1.0.0',
          color: const Color(0xFF3498DB),
          onTap: () => showAboutDialog(
            context: context,
            applicationName: 'Soccer Life',
            applicationVersion: '1.0.0',
            applicationIcon: const Icon(Icons.sports_soccer, size: 48, color: AppColors.primary),
            children: [const Text('Aplicación para gestionar tu carrera futbolística.\n\nDesarrollada con Flutter.')],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard() {
    return _card(
      title: 'CUENTA',
      children: [
        _actionTile(
          icon: Icons.logout,
          label: 'Cerrar Sesión',
          color: AppColors.danger,
          onTap: _cerrarSesion,
          destructive: true,
        ),
        _divider(),
        _actionTile(
          icon: Icons.delete_forever_outlined,
          label: 'Borrar Cuenta',
          sublabel: 'Eliminar permanentemente tu cuenta',
          color: const Color(0xFFC0392B),
          onTap: _confirmarBorrarCuenta,
          destructive: true,
        ),
      ],
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String label,
    String? sublabel,
    required Color color,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: TextStyle(
        color: destructive ? color : AppColors.textPrimary,
        fontWeight: FontWeight.w600, fontSize: 15,
      )),
      subtitle: sublabel != null
          ? Text(sublabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 18),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppColors.border);

  // ── Acciones ───────────────────────────────────────────────────────────────

  void _toggleNotificaciones() async {
    final nuevo = !_notificacionesActivas;
    setState(() => _notificacionesActivas = nuevo);
    await StorageService.guardar('notificaciones_activas', nuevo.toString());
  }



  void _mostrarAyuda() {
    final faqs = [
      {'q': '¿Cómo registro un partido?', 'a': 'Ve a la pantalla "Partidos" y toca el botón "+" para registrar uno nuevo.'},
      {'q': '¿Cómo se calculan mis estadísticas?', 'a': 'Se recalculan automáticamente cada vez que registras, editas o eliminas un partido.'},
      {'q': '¿Puedo usar la app en otro dispositivo?', 'a': 'Sí. Tus datos se sincronizan en el servidor. Solo inicia sesión y todo estará disponible.'},
      {'q': '¿Cómo cambio mi foto de perfil?', 'a': 'Toca tu avatar o el enlace "Cambiar foto" en la pantalla de Perfil.'},
      {'q': '¿Qué pasa si elimino mi cuenta?', 'a': 'Quedará inactiva y no podrás acceder. Para reactivarla contacta a soporte.'},
    ];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, maxChildSize: 0.95, minChildSize: 0.4,
        builder: (_, ctrl) => Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            const SizedBox(height: 12),
            Container(width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Icon(Icons.help_outline, color: Color(0xFF2ECC71), size: 26),
                SizedBox(width: 10),
                Text('Ayuda y Soporte', style: TextStyle(
                    color: AppColors.textPrimary, fontSize: 19, fontWeight: FontWeight.bold)),
              ]),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(controller: ctrl, padding: const EdgeInsets.all(16), children: [
                ...faqs.map((f) => ExpansionTile(
                  iconColor: const Color(0xFF2ECC71),
                  collapsedIconColor: AppColors.textSecondary,
                  title: Text(f['q']!, style: const TextStyle(
                      color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                  children: [Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Text(f['a']!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  )],
                )),
                const Divider(height: 32, color: AppColors.border),
                const Text('¿Necesitas más ayuda?',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 8),
                const Row(children: [
                  Icon(Icons.email_outlined, color: Color(0xFF2ECC71), size: 18),
                  SizedBox(width: 8),
                  Text('soporte@soccerlife.app',
                      style: TextStyle(color: Color(0xFF2ECC71), fontWeight: FontWeight.w500)),
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
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Icon(Icons.delete_forever, color: Color(0xFFC0392B)),
            SizedBox(width: 8),
            Text('Borrar Cuenta', style: TextStyle(color: Color(0xFFC0392B))),
          ]),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              '⚠️ Esta acción es irreversible.\nEscribe tu contraseña para confirmar:',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl, obscureText: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Contraseña', border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ]),
          actions: [
            TextButton(onPressed: cargando ? null : () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC0392B), foregroundColor: Colors.white),
              onPressed: cargando ? null : () async {
                if (passCtrl.text.isEmpty) return;
                setDlg(() => cargando = true);
                final loginRes = await AuthService.login(
                    email: _usuario.email, password: passCtrl.text.trim());
                if (!loginRes['success']) {
                  setDlg(() => cargando = false);
                  _snack('Contraseña incorrecta', Colors.red); return;
                }
                final res = await AuthService.eliminarCuenta();
                setDlg(() => cargando = false);
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                if (res['success'] && mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                } else {
                  _snack(res['message'] ?? 'Error al borrar cuenta', Colors.red);
                }
              },
              child: cargando
                  ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Borrar cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color));
  }

  Widget _card({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Text('$label: ',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14)),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

}

