import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_registration.dart';
import '../services/storage_service.dart';

class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  State<RegistrarsePage> createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> with TickerProviderStateMixin {
  
  // Controladores de animaciones
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Formulario y navegación
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;

  // Controladores de campos de texto
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _clubController = TextEditingController();
  final _edadController = TextEditingController();
  final _estaturaController = TextEditingController();
  final _pesoController = TextEditingController();

  // Nodos de foco
  final _emailFocus = FocusNode();
  final _nombreFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _clubFocus = FocusNode();
  final Map<FocusNode, bool> _focusStates = {};

  // Estados de la interfaz
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _registroExitoso = false;
  String? _posicionSeleccionada;

  final List<Map<String, dynamic>> _posicionesConIcono = [
    {'nombre': 'Arquero', 'icono': Icons.sports_handball},
    {'nombre': 'Defensa Central', 'icono': Icons.shield},
    {'nombre': 'Lateral', 'icono': Icons.compare_arrows},
    {'nombre': 'Volante', 'icono': Icons.sync_alt},
    {'nombre': 'Extremo', 'icono': Icons.double_arrow},
    {'nombre': 'Delantero', 'icono': Icons.sports_soccer},
  ];

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
    _configurarListenersFocus();
    _iniciarAnimacionesEntrada();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _clubController.dispose();
    _emailFocus.dispose();
    _nombreFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _clubFocus.dispose();
    super.dispose();
  }

  void _inicializarAnimaciones() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
  }

  void _configurarListenersFocus() {
    final allFocusNodes = [
      _nombreFocus, _emailFocus,
      _passwordFocus, _confirmPasswordFocus, _clubFocus
    ];
    for (var node in allFocusNodes) {
      _focusStates[node] = false;
      node.addListener(() {
        setState(() => _focusStates[node] = node.hasFocus);
      });
    }
  }

  void _iniciarAnimacionesEntrada() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  // Métodos de validación
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    if (value.toLowerCase() == 'admin@soccerlife.com') return 'El correo ya está registrado';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe incluir mayúscula, minúscula y número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

 

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _previousStep() {
    HapticFeedback.lightImpact();
    setState(() => _currentStep = 0);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> _registrarUsuario() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
       HapticFeedback.heavyImpact();
       return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    try {
      // Llamar a la API para registrar el usuario
      final resultado = await UserRegistrationService.registrarUsuario(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        posicion: _posicionSeleccionada ?? 'Volante',
        club: _clubController.text.trim(),
        edad: int.tryParse(_edadController.text.trim()) ?? 0,
        estatura: double.tryParse(_estaturaController.text.trim().replaceAll(',', '.')) ?? 0.0,
        peso: int.tryParse(_pesoController.text.trim()) ?? 0,
      );
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        if (resultado['success']) {
          // Registro exitoso — mostrar pantalla de éxito de inmediato
          setState(() => _registroExitoso = true);
          HapticFeedback.mediumImpact();

          // Guardar datos localmente (error aquí no bloquea la pantalla de éxito)
          try {
            final data = resultado['data'];
            final usuario = (data is Map && data['usuario'] != null)
                ? data['usuario'] as Map
                : (data is Map ? data : <String, dynamic>{});
            await StorageService.guardarDatosUsuario(
              userId: usuario['_id']?.toString() ?? '',
              email: _emailController.text.trim(),
              nombre: _nombreController.text.trim(),
            );
            await StorageService.guardarPerfilCompleto(
              posicion: _posicionSeleccionada ?? 'Volante',
              club: _clubController.text.trim(),
              edad: int.tryParse(_edadController.text.trim()) ?? 0,
              estatura: (double.tryParse(_estaturaController.text.trim().replaceAll(',', '.')) ?? 0.0) * 100,
              peso: int.tryParse(_pesoController.text.trim()) ?? 0,
            );
          } catch (storageError) {
            // Error de almacenamiento local — no afecta al flujo del usuario
            print('⚠️ Error al guardar datos localmente: $storageError');
          }
        } else if (resultado['emailDuplicado'] == true) {
          // El registro pudo haberse completado pero la respuesta no llegó.
          // Mostramos mensaje amigable para que el usuario inicie sesión.
          HapticFeedback.mediumImpact();
          _mostrarDialogoEmailDuplicado();
        } else {
          // Error en el registro
          HapticFeedback.heavyImpact();
          _mostrarError(resultado['message'] ?? 'Error al registrar usuario');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        HapticFeedback.heavyImpact();
        _mostrarError('Error de conexión: $e');
      }
    }
  }
  
  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _mostrarDialogoEmailDuplicado() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF00f5ff), size: 28),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                '¡Cuenta creada!',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'Tu cuenta fue registrada exitosamente. Por favor inicia sesión para continuar.',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop(); // volver al login
            },
            child: const Text(
              'Ir a iniciar sesión',
              style: TextStyle(
                color: Color(0xFF00f5ff),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_registroExitoso) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            if (_currentStep == 1) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                _buildFootballBackground(),
                SafeArea(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height - kToolbarHeight - MediaQuery.of(context).padding.top,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildFloatingForm(),
                            ],
                          ),
                        ),
                      ),
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

  // Métodos para construir los elementos de la interfaz

  // Crea el fondo con imagen de fútbol y degradado
  Widget _buildFootballBackground() {
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
              Colors.black.withValues(alpha: 0.4),
              Colors.black.withValues(alpha: 0.2),
              Colors.black.withValues(alpha: 0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  // Construye el formulario principal con todos los pasos
  Widget _buildFloatingForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          const SizedBox(height: 0),
          _buildProgressIndicator(),
          const SizedBox(height: 0),
          SizedBox(
            height: 380,
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildInformacionPersonal(),
                _buildInformacionDeportiva(),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  // Construye el header con logo y título
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo de la aplicación (centrado y pegado arriba)
        Center(
          child: Container(
            margin: const EdgeInsets.only(top: 0),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: Image.asset(
                'images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Título principal de la aplicación (más grande)
        Center(
          child: Text(
            'Soccer Life',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF00f5ff),
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  offset: const Offset(2, 2),
                  blurRadius: 10,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
                Shadow(
                  offset: const Offset(-1, -1),
                  blurRadius: 5,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Subtítulo indicando la función (más grande)
        Center(
          child: Text(
            'Crear Cuenta',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w400,
              letterSpacing: 0.7,
            ),
          ),
        ),
      ],
    );
  }

  // Construye el indicador de progreso entre pasos
  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepIndicator(0, 'Personal'),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF00f5ff), Color(0xFF00d4aa)],
                stops: [_currentStep == 0 ? 0.0 : 1.0, 1.0], // Progreso animado
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _buildStepIndicator(1, 'Deportivo'),
      ],
    );
  }

  // Construye un indicador individual para cada paso
  Widget _buildStepIndicator(int step, String label) {
    final isActive = step <= _currentStep;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? const Color(0xFF00f5ff) : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            color: isActive ? const Color(0xFF00f5ff).withValues(alpha: 0.2) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  // Construye los campos del primer paso (información personal)
  Widget _buildInformacionPersonal() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          children: [
            _buildTextField(
              controller: _nombreController,
              focusNode: _nombreFocus,
              label: 'Nombre',
              hint: 'Tu nombre',
              icon: Icons.person_outline,
              validator: (v) => _validateRequired(v, 'El nombre'),
              onFieldSubmitted: (_) => _emailFocus.requestFocus(),
              height: 68,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Correo electrónico',
              hint: 'tu@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              height: 68,
            ),

            const SizedBox(height: 12),
            _buildTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: 'Contraseña',
              hint: 'Mínimo 8 caracteres',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
              height: 68,
              suffixIcon: _buildObscureToggle(
                () => setState(() => _obscurePassword = !_obscurePassword),
                _obscurePassword,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              label: 'Confirmar contraseña',
              hint: 'Repite tu contraseña',
              icon: Icons.lock_outline,
              obscureText: _obscureConfirmPassword,
              validator: _validateConfirmPassword,
              height: 68,
              suffixIcon: _buildObscureToggle(
                () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                _obscureConfirmPassword,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Construye los campos del segundo paso (información deportiva)
  Widget _buildInformacionDeportiva() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Column(
          children: [
            // Club Actual
            _buildTextField(
              controller: _clubController,
              focusNode: _clubFocus,
              label: 'Club actual (opcional)',
              hint: 'Nombre de tu club',
              icon: Icons.shield_outlined,
              height: 60,
            ),
            const SizedBox(height: 12),
            // Posición
            _buildDropdown(),
            const SizedBox(height: 12),
            // Edad
            _buildTextField(
              controller: _edadController,
              label: 'Edad',
              hint: 'Ej: 18',
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              height: 60,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La edad es obligatoria';
                final edad = int.tryParse(v);
                if (edad == null || edad < 12 || edad > 100) return 'Edad inválida';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Estatura
            _buildTextField(
              controller: _estaturaController,
              label: 'Estatura (m)',
              hint: 'Ej: 1.70',
              icon: Icons.height_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              height: 60,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d{0,1}(\.\d{0,2})?')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'La estatura es obligatoria';
                final est = double.tryParse(v.replaceAll(',', '.'));
                if (est == null || est < 1.00 || est > 2.50) return 'Estatura inválida';
                return null;
              },
            ),
            const SizedBox(height: 12),
            // Peso
            _buildTextField(
              controller: _pesoController,
              label: 'Peso (kg)',
              hint: 'Ej: 70',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              height: 60,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'El peso es obligatorio';
                final peso = int.tryParse(v);
                if (peso == null || peso < 30 || peso > 200) return 'Peso inválido';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  // Construye los botones de navegación entre pasos
  Widget _buildNavigationButtons() {
    return Column(
      children: [
        _buildButton(
          onTap: _isLoading ? null : (_currentStep == 0 ? _nextStep : _registrarUsuario),
          text: _currentStep == 0 ? 'Siguiente' : 'Crear mi cuenta',
          isLoading: _isLoading,
        ),
      ],
    );
  }

  // Widgets auxiliares reutilizables

  // Campo de texto con estilo personalizado
  Widget _buildTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onFieldSubmitted,
    bool readOnly = false,
    void Function()? onTap,
    double? height,
  }) {
    final focused = focusNode?.hasFocus ?? false;
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onFieldSubmitted: onFieldSubmitted,
      readOnly: readOnly,
      onTap: onTap,
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
            icon,
            color: focused ? const Color(0xFF00f5ff) : Colors.white.withValues(alpha: 0.6),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffixIcon,
        hintStyle: TextStyle(
          color: focused
              ? const Color(0xFF00f5ff).withValues(alpha: 0.75)
              : Colors.white.withValues(alpha: 0.55),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: focused
            ? const Color(0xFF00f5ff).withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
          borderSide: const BorderSide(
            color: Color(0xFF00f5ff),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFff6b6b),
            width: 1.2,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFff6b6b),
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(color: Color(0xFFff6b6b), fontWeight: FontWeight.w500),
      ),
    );
  }

  // Menú desplegable para seleccionar posición
  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: _posicionSeleccionada,
      onChanged: (value) => setState(() => _posicionSeleccionada = value),
      validator: (v) => v == null ? 'Selecciona tu posición' : null,
      items: _posicionesConIcono.map<DropdownMenuItem<String>>((posicion) {
        return DropdownMenuItem<String>(
          value: posicion['nombre'] as String,
          child: Row(
            children: [
              Icon(
                posicion['icono'] as IconData,
                color: const Color(0xFF00f5ff),
                size: 22,
              ),
              const SizedBox(width: 12),
              Text(
                posicion['nombre'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      dropdownColor: const Color(0xFF1a1a1a),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Posición',
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16, right: 12),
          child: Icon(Icons.sports_soccer_outlined, color: Colors.white.withValues(alpha: 0.6), size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.55),
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFff6b6b), width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFff6b6b), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFff6b6b), fontWeight: FontWeight.w500),
      ),
    );
  }

  // Botón para mostrar/ocultar contraseña
  Widget _buildObscureToggle(VoidCallback onPressed, bool isObscure) {
    return IconButton(
      onPressed: () {
        onPressed();
        HapticFeedback.selectionClick();
      },
      icon: Icon(
        isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white.withValues(alpha: 0.7),
      ),
    );
  }

  // Botón principal con estilo gradiente
  Widget _buildButton({
    required VoidCallback? onTap,
    required String text,
    bool isLoading = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 48,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF00f5ff),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.4),
            blurRadius: 20,
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
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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


  // Pantalla de éxito mostrada tras el registro
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildFootballBackground(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.white.withValues(alpha: 0.1), Colors.white.withValues(alpha: 0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00f5ff), Color(0xFF00d4aa)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00f5ff).withValues(alpha: 0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check, color: Colors.black, size: 50),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          '¡Cuenta creada exitosamente!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF00f5ff),
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Bienvenido, ${_nombreController.text.trim()}\n¡Todo listo para brillar en el campo!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildButton(
                          onTap: () => Navigator.of(context).pop(),
                          text: 'Ir a iniciar sesión',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
