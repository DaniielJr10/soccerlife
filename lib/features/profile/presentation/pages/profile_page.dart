import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/storage_service.dart';
import '../../../hoja_de_vida/presentation/pages/hoja_de_vida_page.dart';
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

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() { _cargando = true; _errorMsg = null; });

    // Intenta cargar desde MongoDB
    final resultado = await ProfileService.obtenerPerfil();
    if (mounted) {
      if (resultado['success'] == true) {
        final u = resultado['usuario'] as Map<String, dynamic>;
        setState(() {
          _usuario = UsuarioModel.fromMap(u);
          _cargando = false;
        });
      } else {
        // Fallback a caché local
        final cached = await StorageService.obtenerUsuarioModel();
        setState(() {
          _usuario = cached;
          _cargando = false;
          _errorMsg = 'Sin conexión — mostrando datos locales';
        });
      }
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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primary),
            tooltip: 'Editar perfil',
            onPressed: _cargando ? null : _editarPerfil,
          ),
        ],
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
                  _buildAccountCard(),
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
    final initials = _initials(_usuario.nombre);
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(initials,
                style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary)),
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

  Widget _buildAccountCard() {
    return _card(
      title: 'Cuenta',
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.logout, color: AppColors.danger),
          title: Text('Cerrar sesión',
              style:
                  TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600)),
          onTap: _cerrarSesion,
        ),
      ],
    );
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

