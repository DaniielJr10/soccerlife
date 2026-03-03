import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../models/usuario_model.dart';
import '../../../../services/profile_service.dart';

class PersonalInfoPage extends StatefulWidget {
  final UsuarioModel usuario;
  final Uint8List? photoBytes;
  final VoidCallback? onEdited;

  const PersonalInfoPage({
    super.key,
    required this.usuario,
    this.photoBytes,
    this.onEdited,
  });

  @override
  State<PersonalInfoPage> createState() => _PersonalInfoPageState();
}

class _PersonalInfoPageState extends State<PersonalInfoPage> {
  static const _cyan = Color(0xFF00f5ff);
  bool _editando = false;
  bool _guardando = false;
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nombre;
  late final TextEditingController _posicion;
  late final TextEditingController _club;
  late final TextEditingController _edad;
  late final TextEditingController _estatura;
  late final TextEditingController _peso;
  late UsuarioModel _usuario;

  static const _posiciones = [
    'Arquero', 'Defensa Central', 'Lateral',
    'Volante', 'Extremo', 'Delantero',
  ];

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
    _initControllers(_usuario);
  }

  void _initControllers(UsuarioModel u) {
    _nombre   = TextEditingController(text: u.nombre);
    _posicion = TextEditingController(text: u.posicion);
    _club     = TextEditingController(text: u.club);
    _edad     = TextEditingController(text: u.edad > 0 ? '${u.edad}' : '');
    _estatura = TextEditingController(
        text: u.estatura > 0 ? '${u.estatura.toStringAsFixed(0)}' : '');
    _peso     = TextEditingController(text: u.peso > 0 ? '${u.peso}' : '');
  }

  @override
  void dispose() {
    for (final c in [_nombre, _posicion, _club, _edad, _estatura, _peso]) {
      c.dispose();
    }
    super.dispose();
  }

  void _toggleEditar() {
    setState(() {
      if (_editando) {
        _nombre.text   = _usuario.nombre;
        _posicion.text = _usuario.posicion;
        _club.text     = _usuario.club;
        _edad.text     = _usuario.edad > 0 ? '${_usuario.edad}' : '';
        _estatura.text = _usuario.estatura > 0
            ? '${_usuario.estatura.toStringAsFixed(0)}'
            : '';
        _peso.text     = _usuario.peso > 0 ? '${_usuario.peso}' : '';
      }
      _editando = !_editando;
    });
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    HapticFeedback.mediumImpact();
    setState(() => _guardando = true);
    final result = await ProfileService.actualizarPerfil(
      nombre: _nombre.text.trim(),
      posicion: _posicion.text.trim(),
      club: _club.text.trim(),
      edad: int.tryParse(_edad.text) ?? 0,
      estatura: double.tryParse(_estatura.text) ?? 0.0,
      peso: int.tryParse(_peso.text) ?? 0,
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (result['success'] == true) {
      final nuevo = UsuarioModel.fromMap(
          result['usuario'] as Map<String, dynamic>);
      setState(() {
        _usuario = nuevo;
        _editando = false;
      });
      widget.onEdited?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Perfil actualizado ✓'),
            backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(result['message'] ?? 'Error al guardar'),
            backgroundColor: AppColors.danger),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        centerTitle: true,
        title: const Text(
          'Información Personal',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(
              context, _usuario != widget.usuario ? _usuario : null),
        ),
        actions: [
          TextButton(
            onPressed: _editando ? null : _toggleEditar,
            child: Text(
              'Editar',
              style: TextStyle(
                color: _editando ? AppColors.textMuted : _cyan,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          children: [
            // Foto
            Center(child: _buildPhotoFrame()),
            const SizedBox(height: 28),
            // Info de perfil (incluye datos físicos)
            _sectionLabel('INFORMACIÓN DE PERFIL'),
            const SizedBox(height: 12),
            _editando ? _buildInfoEdit() : _buildInfoView(),
            if (_editando) ...[
              const SizedBox(height: 28),
              _buildActionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Marco de foto ─────────────────────────────────────────────────────────

  Widget _buildPhotoFrame() {
    final hasPhoto = widget.photoBytes != null;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 118,
          height: 118,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _cyan.withValues(alpha: 0.3),
                blurRadius: 24,
                spreadRadius: 3,
              ),
            ],
          ),
        ),
        Container(
          width: 114,
          height: 114,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_cyan, Color(0xFF0077ff), _cyan],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        ),
        Container(
          width: 108,
          height: 108,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.background,
          ),
        ),
        ClipOval(
          child: SizedBox(
            width: 102,
            height: 102,
            child: hasPhoto
                ? Image.memory(widget.photoBytes!,
                    fit: BoxFit.cover, gaplessPlayback: true)
                : Container(
                    color: const Color(0xFF0d1f2d),
                    child: Center(
                      child: Text(
                        _usuario.iniciales,
                        style: const TextStyle(
                          color: _cyan,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Datos físicos – vista ─────────────────────────────────────────────────

  // ── Info de perfil – vista ────────────────────────────────────────────────

  Widget _buildInfoView() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _infoTile(Icons.person_rounded, 'Nombre',
              _usuario.nombre.isNotEmpty ? _usuario.nombre : '—',
              first: true),
          _div(),
          _infoTile(Icons.email_rounded, 'Correo',
              _usuario.email.isNotEmpty ? _usuario.email : '—'),
          _div(),
          _infoTile(Icons.shield_rounded, 'Club',
              _usuario.club.isNotEmpty ? _usuario.club : '—'),
          _div(),
          _infoTile(Icons.sports_soccer_rounded, 'Posición',
              _usuario.posicion.isNotEmpty ? _usuario.posicion : '—'),
          _div(),
          _infoTile(Icons.cake_outlined, 'Edad',
              _usuario.edad > 0 ? '${_usuario.edad} años' : '—'),
          _div(),
          _infoTile(Icons.height, 'Estatura',
              _usuario.estatura > 0 ? '${_usuario.estatura.toStringAsFixed(0)} cm' : '—'),
          _div(),
          _infoTile(Icons.monitor_weight_outlined, 'Peso',
              _usuario.peso > 0 ? '${_usuario.peso} kg' : '—',
              last: true),
        ],
      ),
    );
  }

  // ── Info de perfil – edición ──────────────────────────────────────────────

  Widget _buildInfoEdit() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _cyan.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _editField(_nombre, 'Nombre', Icons.person_rounded,
              validator: (v) =>
                  v?.trim().isEmpty == true ? 'Requerido' : null),
          const SizedBox(height: 12),
          _editField(_club, 'Club / Equipo', Icons.shield_rounded),
          const SizedBox(height: 12),
          _posicionDropdown(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _editField(_edad, 'Edad', Icons.cake_outlined,
                      inputType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: _editField(_estatura, 'Estatura (cm)', Icons.height,
                      inputType: TextInputType.number)),
              const SizedBox(width: 10),
              Expanded(
                  child: _editField(_peso, 'Peso (kg)',
                      Icons.monitor_weight_outlined,
                      inputType: TextInputType.number)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Botones de acción ─────────────────────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _guardando ? null : _toggleEditar,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Cancelar',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.check_rounded, size: 20),
            label: Text(
              _guardando ? 'Guardando...' : 'Guardar cambios',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: Colors.black,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      );

  Widget _infoTile(IconData icon, String label, String value,
      {bool first = false, bool last = false}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, first ? 16 : 12, 16, last ? 16 : 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _cyan, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _div() => const Divider(
      height: 1, indent: 66, color: AppColors.border);

  Widget _editField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: _cyan, size: 18),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cyan, width: 1.5)),
      ),
    );
  }

  Widget _posicionDropdown() {
    return DropdownButtonFormField<String>(
      value: _posiciones.contains(_posicion.text) ? _posicion.text : null,
      decoration: InputDecoration(
        labelText: 'Posición',
        labelStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 13),
        prefixIcon:
            const Icon(Icons.sports_soccer_rounded, color: _cyan, size: 18),
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _cyan, width: 1.5)),
      ),
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      items: _posiciones
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (v) => setState(() => _posicion.text = v ?? ''),
    );
  }
}
