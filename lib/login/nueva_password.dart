import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_recuperar.dart';

class NuevaPasswordPage extends StatefulWidget {
  final String token;

  const NuevaPasswordPage({super.key, required this.token});

  @override
  State<NuevaPasswordPage> createState() => _NuevaPasswordPageState();
}

class _NuevaPasswordPageState extends State<NuevaPasswordPage>
    with TickerProviderStateMixin {
  // Controladores de animaciones
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _passwordFocus = FocusNode();
  final _confirmarPasswordFocus = FocusNode();

  // Estados de la interfaz
  bool _obscurePassword = true;
  bool _obscureConfirmar = true;
  bool _guardando = false;
  bool _passwordFocused = false;
  bool _confirmarFocused = false;
  bool _exitoso = false;

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
    _configurarListenersFocus();
    _iniciarAnimaciones();
  }

  void _inicializarAnimaciones() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _configurarListenersFocus() {
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
    _confirmarPasswordFocus.addListener(() {
      setState(() => _confirmarFocused = _confirmarPasswordFocus.hasFocus);
    });
  }

  void _iniciarAnimaciones() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    _passwordFocus.dispose();
    _confirmarPasswordFocus.dispose();
    super.dispose();
  }

  // ── Lógica ───────────────────────────────────────────────────────────────

  Future<void> _guardarNuevaPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      HapticFeedback.heavyImpact();
      return;
    }

    setState(() => _guardando = true);
    HapticFeedback.lightImpact();

    final resp = await UserRecuperarService.cambiarPasswordConToken(
      token: widget.token,
      nuevaPassword: _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _guardando = false);

    if (resp['success'] == true) {
      HapticFeedback.mediumImpact();
      setState(() => _exitoso = true);
      _scaleController.reset();
      _scaleController.forward();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['message'] ?? 'Error al cambiar la contraseña'),
          backgroundColor: const Color(0xFFff6b6b),
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  void _irAlLogin() {
    HapticFeedback.lightImpact();
    // Volver hasta la pantalla de login eliminando toda la pila de navegación
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // ── Validadores ───────────────────────────────────────────────────────────

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.trim().length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  String? _validateConfirmarPassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Debes confirmar tu contraseña';
    }
    if (value.trim() != _passwordController.text.trim()) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_exitoso) return _buildPantallaExito();

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _irAlLogin,
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                _buildFondo(),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 20),
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildFormulario(),
                        ),
                        SizedBox(
                            height:
                                MediaQuery.of(context).viewInsets.bottom + 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFondo() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/championsfondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.1),
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.asset('images/logo.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 28),
        Center(
          child: Text(
            'Soccer Life',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF00f5ff),
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
                Shadow(
                  offset: const Offset(-1, -1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Nueva Contraseña',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildFormulario() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.15),
                    Colors.white.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF00b4db),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Crea una contraseña segura con al menos 8 caracteres para proteger tu cuenta.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Campo nueva contraseña
            _buildPasswordField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: 'Nueva Contraseña',
              isFocused: _passwordFocused,
              obscure: _obscurePassword,
              onToggleObscure: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              validator: _validatePassword,
            ),

            const SizedBox(height: 20),

            // Campo confirmar contraseña
            _buildPasswordField(
              controller: _confirmarPasswordController,
              focusNode: _confirmarPasswordFocus,
              label: 'Confirmar Contraseña',
              isFocused: _confirmarFocused,
              obscure: _obscureConfirmar,
              onToggleObscure: () =>
                  setState(() => _obscureConfirmar = !_obscureConfirmar),
              validator: _validateConfirmarPassword,
            ),

            const SizedBox(height: 32),

            // Botón guardar
            _buildButton(
              onTap: _guardando ? null : _guardarNuevaPassword,
              text: 'Guardar Contraseña',
              isLoading: _guardando,
            ),

            const SizedBox(height: 16),

            // Link volver
            TextButton(
              onPressed: _irAlLogin,
              child: Text(
                'Volver al inicio de sesión',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required bool isFocused,
    required bool obscure,
    required VoidCallback onToggleObscure,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.85),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: label,
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(
            Icons.lock_outline,
            color: isFocused
                ? const Color(0xFF00f5ff)
                : Colors.white.withValues(alpha: 0.6),
            size: 22,
          ),
        ),
        prefixIconConstraints:
            const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: IconButton(
            icon: Icon(
              obscure
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isFocused
                  ? const Color(0xFF00f5ff)
                  : Colors.white.withValues(alpha: 0.6),
              size: 22,
            ),
            onPressed: onToggleObscure,
          ),
        ),
        hintStyle: TextStyle(
          color: isFocused
              ? const Color(0xFF00f5ff).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.55),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: isFocused
            ? const Color(0xFF00f5ff).withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.08),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF00f5ff), width: 2.0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFff6b6b), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFff6b6b), width: 1.5),
        ),
        errorStyle: const TextStyle(
          color: Color(0xFFff6b6b),
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }

  Widget _buildButton({
    required VoidCallback? onTap,
    required String text,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF00f5ff),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ── Pantalla de éxito ─────────────────────────────────────────────────────

  Widget _buildPantallaExito() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildFondo(),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.15),
                      Colors.white.withValues(alpha: 0.05),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono de éxito
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2ecc71).withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                      ).createShader(bounds),
                      child: const Text(
                        '¡Contraseña Actualizada!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Tu contraseña ha sido cambiada exitosamente. Ya puedes iniciar sesión con tu nueva contraseña.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 32),

                    _buildButton(
                      onTap: _irAlLogin,
                      text: 'Ir al inicio de sesión',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
