import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/auth_service.dart';

/// Página para cambiar la contraseña del usuario autenticado.
/// Diseño moderno con indicador de fortaleza y validaciones en tiempo real.
class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage>
    with SingleTickerProviderStateMixin {
  // ── Controladores ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _actCtrl  = TextEditingController();
  final _newCtrl  = TextEditingController();
  final _confCtrl = TextEditingController();

  // ── Estado de la UI ───────────────────────────────────────────────────────
  bool _verAct   = false;
  bool _verNew   = false;
  bool _verConf  = false;
  bool _cargando = false;

  // Fortaleza de la contraseña (0-4)
  int _strength = 0;
  String _strengthLabel = '';
  Color _strengthColor  = Colors.transparent;

  // ── Animación de entrada ──────────────────────────────────────────────────
  late final AnimationController _animCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _animCtrl,
    curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));

  // ── Ciclo de vida ─────────────────────────────────────────────────────────
  @override
  void dispose() {
    _actCtrl.dispose();
    _newCtrl.dispose();
    _confCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  // ── Lógica ────────────────────────────────────────────────────────────────

  void _evaluarFortaleza(String value) {
    int score = 0;
    if (value.length >= 8)                                score++;
    if (RegExp(r'[A-Z]').hasMatch(value))                 score++;
    if (RegExp(r'[0-9]').hasMatch(value))                 score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value)) score++;

    final labels = ['', 'Débil', 'Regular', 'Buena', 'Fuerte'];
    final colors = [
      Colors.transparent,
      AppColors.danger,
      AppColors.warning,
      AppColors.info,
      AppColors.success,
    ];
    setState(() {
      _strength      = score;
      _strengthLabel = value.isEmpty ? '' : labels[score];
      _strengthColor = value.isEmpty ? Colors.transparent : colors[score];
    });
  }

  Future<void> _guardar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _cargando = true);
    final res = await AuthService.cambiarPassword(
      actual: _actCtrl.text.trim(),
      nueva:  _newCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _cargando = false);

    if (res['success'] == true) {
      _snack('¡Contraseña cambiada con éxito!', AppColors.success);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) Navigator.pop(context);
    } else {
      _snack(res['message'] ?? 'Error al cambiar contraseña', AppColors.danger);
    }
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Icon(
          color == AppColors.success ? Icons.check_circle_outline : Icons.error_outline,
          color: Colors.white, size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
      ]),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.all(16),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Encabezado ─────────────────────────────────────────
                    _buildHeader(),
                    const SizedBox(height: 32),

                    // ── Campo contraseña actual ────────────────────────────
                    _sectionLabel('Contraseña actual'),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: _actCtrl,
                      label: 'Ingresa tu contraseña actual',
                      visible: _verAct,
                      onToggle: () => setState(() => _verAct = !_verAct),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),

                    // ── Separador con gradiente ────────────────────────────
                    _divider(),
                    const SizedBox(height: 28),

                    // ── Campo nueva contraseña ─────────────────────────────
                    _sectionLabel('Nueva contraseña'),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: _newCtrl,
                      label: 'Mínimo 6 caracteres',
                      visible: _verNew,
                      onToggle: () => setState(() => _verNew = !_verNew),
                      onChanged: _evaluarFortaleza,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        if (v.length < 6) return 'Mínimo 6 caracteres';
                        if (v == _actCtrl.text.trim()) {
                          return 'Debe ser diferente a tu contraseña actual';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // ── Indicador de fortaleza ─────────────────────────────
                    if (_newCtrl.text.isNotEmpty) _buildStrengthIndicator(),
                    const SizedBox(height: 20),

                    // ── Campo confirmar contraseña ─────────────────────────
                    _sectionLabel('Confirmar nueva contraseña'),
                    const SizedBox(height: 8),
                    _PasswordField(
                      controller: _confCtrl,
                      label: 'Repite la nueva contraseña',
                      visible: _verConf,
                      onToggle: () => setState(() => _verConf = !_verConf),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Campo requerido';
                        if (v != _newCtrl.text) return 'Las contraseñas no coinciden';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // ── Consejos ───────────────────────────────────────────
                    _buildTips(),
                    const SizedBox(height: 36),

                    // ── Botón guardar ──────────────────────────────────────
                    _buildSaveButton(),
                    const SizedBox(height: 12),
                    _buildCancelButton(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Widgets auxiliares ────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E44AD), Color(0xFF6C3483)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E44AD).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Icons.lock_reset_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cambiar contraseña',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Actualiza tu contraseña de acceso',
              style: TextStyle(
                color: AppColors.textSecondary.withValues(alpha: 0.8),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      );

  Widget _divider() => Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.border, Colors.transparent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: const Text(
                'Nueva contraseña',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.border, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      );

  Widget _buildStrengthIndicator() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            final active = i < _strength;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 5,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: active ? _strengthColor : AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
        if (_strengthLabel.isNotEmpty) ...[
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              'Fortaleza: $_strengthLabel',
              key: ValueKey(_strengthLabel),
              style: TextStyle(
                color: _strengthColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTips() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates_outlined,
                  color: AppColors.primary, size: 16),
              const SizedBox(width: 6),
              const Text(
                'Consejos de seguridad',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...[
            'Usa mayúsculas y minúsculas',
            'Incluye números y símbolos',
            'Mínimo 8 caracteres recomendados',
          ].map((t) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: AppColors.primary.withValues(alpha: 0.7), size: 13),
                    const SizedBox(width: 6),
                    Text(t,
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _cargando ? null : _guardar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8E44AD),
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          disabledBackgroundColor: const Color(0xFF8E44AD).withValues(alpha: 0.5),
        ),
        child: _cargando
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: Colors.white),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_reset_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Guardar contraseña',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: _cargando ? null : () => Navigator.pop(context),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text('Cancelar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}

// ── Widget de campo de contraseña ────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    this.onChanged,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
            color: AppColors.textSecondary.withValues(alpha: 0.6), fontSize: 14),
        filled: true,
        fillColor: AppColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF8E44AD), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
        prefixIcon: const Icon(Icons.lock_outline_rounded,
            color: Color(0xFF8E44AD), size: 20),
        suffixIcon: IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              visible
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              key: ValueKey(visible),
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
