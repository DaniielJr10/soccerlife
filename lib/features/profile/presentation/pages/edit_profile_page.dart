import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/profile_service.dart';

/// Página de edición de perfil con dark theme.
/// Persiste todos los datos en MongoDB vía [ProfileService].
class EditProfilePage extends StatefulWidget {
  final Map<String, dynamic> datosActuales;
  const EditProfilePage({super.key, required this.datosActuales});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  bool _guardando = false;

  late final TextEditingController _nombre;
  late final TextEditingController _posicion;
  late final TextEditingController _club;
  late final TextEditingController _edad;
  late final TextEditingController _estatura;
  late final TextEditingController _peso;

  static const _posiciones = [
    'Arquero', 'Defensa Central', 'Lateral',
    'Volante', 'Extremo', 'Delantero',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.datosActuales;
    _nombre = TextEditingController(text: d['nombre']?.toString() ?? '');
    _posicion = TextEditingController(text: d['posicion']?.toString() ?? '');
    _club = TextEditingController(text: d['club']?.toString() ?? '');
    _edad = TextEditingController(
        text: d['edad'] != null && d['edad'] != 0 ? '${d['edad']}' : '');
    _estatura = TextEditingController(
        text: d['estatura'] != null && d['estatura'] != 0 ? '${d['estatura']}' : '');
    _peso = TextEditingController(
        text: d['peso'] != null && d['peso'] != 0 ? '${d['peso']}' : '');
  }

  @override
  void dispose() {
    for (final c in [_nombre, _posicion, _club, _edad, _estatura, _peso]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil guardado ✓'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(result['usuario']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al guardar'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Editar perfil'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_nombre, 'Nombre', Icons.person_outline,
                validator: (v) => v?.isEmpty == true ? 'Requerido' : null),
            const SizedBox(height: 14),
            _posicionDropdown(),
            const SizedBox(height: 14),
            _field(_club, 'Club / Equipo', Icons.shield_outlined),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(
                  child: _field(_edad, 'Edad', Icons.cake_outlined,
                      inputType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                  child: _field(_estatura, 'Estatura (cm)', Icons.height,
                      inputType: TextInputType.number)),
            ]),
            const SizedBox(height: 14),
            _field(_peso, 'Peso (kg)', Icons.monitor_weight_outlined,
                inputType: TextInputType.number),
            const SizedBox(height: 28),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.background),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_guardando ? 'Guardando...' : 'Guardar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.background,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: inputType,
      style: const TextStyle(color: AppColors.textPrimary),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
    );
  }

  Widget _posicionDropdown() {
    return DropdownButtonFormField<String>(
      value: _posiciones.contains(_posicion.text) ? _posicion.text : null,
      decoration: InputDecoration(
        labelText: 'Posición',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.sports_soccer,
            color: AppColors.primary, size: 20),
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5)),
      ),
      dropdownColor: AppColors.card,
      style: const TextStyle(color: AppColors.textPrimary),
      items: _posiciones
          .map((p) => DropdownMenuItem(value: p, child: Text(p)))
          .toList(),
      onChanged: (v) => _posicion.text = v ?? '',
    );
  }
}
