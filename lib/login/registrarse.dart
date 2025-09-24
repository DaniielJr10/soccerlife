import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 🚀 PANTALLA DE REGISTRO PREMIUM - SOCCER LIFE
///
/// UI de registro ultra-moderna con 2 pasos, animaciones y un diseño
/// consistente con la pantalla de inicio de sesión.
class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  State<RegistrarsePage> createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> with TickerProviderStateMixin {
  // ===== 🎬 CONTROLADORES DE ANIMACIÓN =====
  // Controlan las animaciones de fade y slide para una entrada suave.
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ===== 📝 ESTADOS DEL FORMULARIO =====
  // Clave global para identificar y validar el formulario.
  final _formKey = GlobalKey<FormState>();
  // Controlador para manejar el PageView de los pasos de registro.
  final _pageController = PageController();
  // Mantiene el paso actual del formulario (0 para personal, 1 para deportivo).
  int _currentStep = 0;

  // ===== ✍️ CONTROLADORES DE TEXTO =====
  // Gestionan el contenido de cada campo de texto del formulario.
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _clubController = TextEditingController();

  // ===== 🎯 NODOS DE FOCO =====
  // Gestionan el foco de los campos para mejorar la navegación y los efectos visuales.
  final _emailFocus = FocusNode();
  final _nombreFocus = FocusNode();
  final _apellidoFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  final _clubFocus = FocusNode();
  // Mapa para rastrear el estado de foco de cada nodo y aplicar estilos dinámicos.
  final Map<FocusNode, bool> _focusStates = {};

  // ===== 🎛️ ESTADOS DE LA INTERFAZ =====
  // Controlan la visibilidad de las contraseñas.
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  // Controla si se muestra el indicador de carga.
  bool _isLoading = false;
  // Controla si se muestra la pantalla de éxito.
  bool _registroExitoso = false;
  // Almacena la fecha de nacimiento seleccionada.
  DateTime? _fechaNacimiento;
  // Almacena la posición de fútbol seleccionada.
  String? _posicionSeleccionada;

  // Lista de posiciones disponibles para el jugador.
  final List<String> _posiciones = [
    'Arquero', 'Defensa Central', 'Lateral', 'Volante', 'Extremo', 'Delantero',
  ];

  /// Se ejecuta una vez cuando el widget se inserta en el árbol de widgets.
  /// Aquí se inicializan las animaciones y los listeners.
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
    _startEntryAnimation();
  }

  /// Libera todos los recursos (controladores, nodos de foco) para evitar fugas de memoria.
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pageController.dispose();
    _emailController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _fechaNacimientoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _telefonoController.dispose();
    _clubController.dispose();
    _emailFocus.dispose();
    _nombreFocus.dispose();
    _apellidoFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _telefonoFocus.dispose();
    _clubFocus.dispose();
    super.dispose();
  }

  // ===== 🎨 LÓGICA DE LA INTERFAZ Y ANIMACIONES =====

  /// Inicializa los controladores y las curvas de las animaciones de entrada.
  void _initializeAnimations() {
    _fadeController = AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic);
    _slideController = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
  }

  /// Configura listeners para cada nodo de foco.
  /// Esto permite cambiar la UI dinámicamente cuando un campo está seleccionado.
  void _setupFocusListeners() {
    final allFocusNodes = [
      _nombreFocus, _apellidoFocus, _emailFocus, _telefonoFocus,
      _passwordFocus, _confirmPasswordFocus, _clubFocus
    ];
    for (var node in allFocusNodes) {
      _focusStates[node] = false;
      node.addListener(() {
        setState(() => _focusStates[node] = node.hasFocus);
      });
    }
  }

  /// Inicia las animaciones de entrada con un pequeño retraso.
  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  // ===== 🔐 LÓGICA DE VALIDACIÓN Y REGISTRO =====

  /// Valida el formato del correo electrónico.
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    // Simulación para verificar si el correo ya existe.
    if (value.toLowerCase() == 'admin@soccerlife.com') return 'El correo ya está registrado';
    return null;
  }

  /// Valida la fortaleza de la contraseña.
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es obligatoria';
    if (value.length < 8) return 'Debe tener al menos 8 caracteres';
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe incluir mayúscula, minúscula y número';
    }
    return null;
  }

  /// Valida que las contraseñas coincidan.
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != _passwordController.text) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Valida el formato del número de teléfono.
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es obligatorio';
    if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'El número de teléfono es inválido';
    }
    return null;
  }

  /// Valida que un campo no esté vacío.
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName es obligatorio';
    return null;
  }

  /// Muestra un selector de fecha y actualiza el estado.
  Future<void> _selectDate() async {
    HapticFeedback.selectionClick();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 4380)), // 12 años
      builder: (context, child) {
        // Tema oscuro para el selector de fecha, a juego con la UI.
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00f5ff),
              onPrimary: Colors.black,
              surface: Color(0xFF1a1a1a),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF101010),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaNacimiento = picked;
        _fechaNacimientoController.text =
            '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      });
    }
  }

  /// Valida el paso actual y avanza al siguiente.
  void _nextStep() {
    HapticFeedback.lightImpact();
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      HapticFeedback.heavyImpact(); // Feedback de error si la validación falla.
    }
  }

  /// Retrocede al paso anterior.
  void _previousStep() {
    HapticFeedback.lightImpact();
    setState(() => _currentStep = 0);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOutCubic,
    );
  }

  /// Valida el formulario final y simula el registro de usuario.
  Future<void> _registrarUsuario() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
       HapticFeedback.heavyImpact();
       return;
    }
    
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    
    // Simula una llamada a la API.
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _registroExitoso = true; // Muestra la pantalla de éxito.
      });
      HapticFeedback.mediumImpact();
    }
  }

  // ===== 🎨 CONSTRUCCIÓN DE LA INTERFAZ PREMIUM =====

  /// Método principal que construye la UI de la pantalla.
  @override
  Widget build(BuildContext context) {
    // Si el registro fue exitoso, muestra la pantalla de éxito.
    if (_registroExitoso) {
      return _buildSuccessScreen();
    }

    // Construye la pantalla principal de registro.
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                _buildFootballBackground(), // Fondo de pantalla.
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 40),
                                _buildFloatingForm(), // Contenido principal del formulario.
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Construye el fondo con la imagen de fútbol y un degradado oscuro.
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
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.5),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  /// Construye el formulario flotante que contiene todos los elementos de registro.
  Widget _buildFloatingForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPremiumHeader(),
          const SizedBox(height: 24),
          _buildProgressIndicator(),
          const SizedBox(height: 24),
          SizedBox(
            height: 450, // Altura fija para el PageView que contiene los pasos.
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll por gesto.
              children: [
                _buildInformacionPersonal(), // Paso 1
                _buildInformacionDeportiva(), // Paso 2
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  /// Construye el encabezado con el logo, título y subtítulo (IGUAL QUE INICIO DE SESIÓN).
  Widget _buildPremiumHeader() {
    return Column(
      children: [
        // Logo limpio y redondito flotando sobre tu imagen (IGUAL QUE INICIO DE SESIÓN)
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(60),
            // 🎯 Sombra sutil para que resalte sobre tu imagen de fondo
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Título principal limpio y profesional (IGUAL QUE INICIO DE SESIÓN)
        Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [
                Color(0xFF00f5ff),
                Color(0xFF00d4aa),
                Color(0xFFffffff),
              ],
            ).createShader(bounds),
            child: const Text(
              'Soccer Life',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Subtítulo elegante y limpio
        Center(
          child: Text(
            'Crear Cuenta',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// Construye el indicador de progreso de los pasos (Personal -> Deportivo).
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
                stops: [_currentStep == 0 ? 0.0 : 1.0, 1.0], // Anima el degradado.
              ),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ),
        _buildStepIndicator(1, 'Deportivo'),
      ],
    );
  }

  /// Construye un círculo y etiqueta para un paso individual del indicador.
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
              color: isActive ? const Color(0xFF00f5ff) : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
            color: isActive ? const Color(0xFF00f5ff).withOpacity(0.2) : Colors.transparent,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Construye los campos del formulario para la información personal (Paso 1).
  Widget _buildInformacionPersonal() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _buildPremiumTextField(
            controller: _nombreController,
            focusNode: _nombreFocus,
            label: 'Nombre',
            hint: 'Tu nombre',
            icon: Icons.person_outline,
            validator: (v) => _validateRequired(v, 'El nombre'),
            onFieldSubmitted: (_) => _apellidoFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _apellidoController,
            focusNode: _apellidoFocus,
            label: 'Apellido',
            hint: 'Tu apellido',
            icon: Icons.person_outline,
            validator: (v) => _validateRequired(v, 'El apellido'),
            onFieldSubmitted: (_) => _selectDate(),
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _fechaNacimientoController,
            label: 'Fecha de nacimiento',
            hint: 'DD/MM/YYYY',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: _selectDate,
            validator: (v) => _fechaNacimiento == null ? 'Selecciona tu fecha' : null,
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _emailController,
            focusNode: _emailFocus,
            label: 'Correo electrónico',
            hint: 'tu@email.com',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: _validateEmail,
            onFieldSubmitted: (_) => _telefonoFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
           _buildPremiumTextField(
            controller: _telefonoController,
            focusNode: _telefonoFocus,
            label: 'Teléfono',
            hint: '300 123 4567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validatePhone,
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            label: 'Contraseña',
            hint: 'Mínimo 8 caracteres',
            icon: Icons.lock_outline,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            suffixIcon: _buildObscureToggle(
              () => setState(() => _obscurePassword = !_obscurePassword),
              _obscurePassword,
            ),
          ),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _confirmPasswordController,
            focusNode: _confirmPasswordFocus,
            label: 'Confirmar contraseña',
            hint: 'Repite tu contraseña',
            icon: Icons.lock_outline,
            obscureText: _obscureConfirmPassword,
            validator: _validateConfirmPassword,
            suffixIcon: _buildObscureToggle(
              () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              _obscureConfirmPassword,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los campos del formulario para la información deportiva (Paso 2).
  Widget _buildInformacionDeportiva() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        children: [
          _buildPremiumDropdown(),
          const SizedBox(height: 16),
          _buildPremiumTextField(
            controller: _clubController,
            focusNode: _clubFocus,
            label: 'Club actual (opcional)',
            hint: 'Nombre de tu club',
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }

  /// Construye los botones de navegación (Siguiente, Anterior, Crear cuenta).
  Widget _buildNavigationButtons() {
    return Column(
      children: [
        _buildPremiumButton(
          onTap: _isLoading ? null : (_currentStep == 0 ? _nextStep : _registrarUsuario),
          text: _currentStep == 0 ? 'Siguiente' : 'Crear mi cuenta',
          isLoading: _isLoading,
        ),
        const SizedBox(height: 16),
        // Muestra el botón "Anterior" solo en el segundo paso.
        if (_currentStep == 1)
          _buildGlassButton(
            onTap: _previousStep,
            text: 'Anterior',
          ),
      ],
    );
  }

  // ===== 🧩 WIDGETS REUTILIZABLES PREMIUM =====

  /// Widget reutilizable para un campo de texto con estilo premium.
  Widget _buildPremiumTextField({
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
  }) {
    final isFocused = focusNode != null && (_focusStates[focusNode] ?? false);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused ? const Color(0xFF00f5ff).withOpacity(0.8) : Colors.white.withOpacity(0.3),
          width: isFocused ? 1.5 : 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.black.withOpacity(isFocused ? 0.3 : 0.2),
            Colors.black.withOpacity(isFocused ? 0.25 : 0.15),
          ],
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.25),
            blurRadius: 15,
          ),
        ] : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        validator: validator,
        obscureText: obscureText,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onFieldSubmitted: onFieldSubmitted,
        readOnly: readOnly,
        onTap: onTap,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: isFocused ? const Color(0xFF00f5ff) : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          errorStyle: const TextStyle(color: Color(0xFFff6b6b), fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
  
  /// Widget reutilizable para un menú desplegable con estilo premium.
  Widget _buildPremiumDropdown() {
    return DropdownButtonFormField<String>(
      value: _posicionSeleccionada,
      onChanged: (value) => setState(() => _posicionSeleccionada = value),
      validator: (v) => v == null ? 'Selecciona tu posición' : null,
      items: _posiciones.map((posicion) {
        return DropdownMenuItem(
          value: posicion,
          child: Text(posicion),
        );
      }).toList(),
      dropdownColor: const Color(0xFF1a1a1a),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: 'Posición',
        prefixIcon: Icon(Icons.sports_soccer_outlined, color: Colors.white.withOpacity(0.7)),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.black.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: const Color(0xFF00f5ff).withOpacity(0.8), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFff6b6b), fontWeight: FontWeight.w500),
      ),
    );
  }

  /// Construye el botón para mostrar/ocultar la contraseña.
  Widget _buildObscureToggle(VoidCallback onPressed, bool isObscure) {
    return IconButton(
      onPressed: () {
        onPressed();
        HapticFeedback.selectionClick();
      },
      icon: Icon(
        isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }

  /// Construye el botón principal con gradiente y efecto de sombra.
  Widget _buildPremiumButton({
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
        gradient: const LinearGradient(
          colors: [Color(0xFF00f5ff), Color(0xFF00d4aa)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  /// Construye un botón secundario con efecto de cristal.
  Widget _buildGlassButton({required VoidCallback onTap, required String text}) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              color: Colors.white.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye la pantalla de éxito que se muestra después de un registro correcto.
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
                        colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
                                color: const Color(0xFF00f5ff).withOpacity(0.4),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.check, color: Colors.black, size: 50),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          '¡Bienvenido, ${_nombreController.text}!',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tu cuenta ha sido creada. \n¡Es hora de brillar en el campo!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildPremiumButton(
                          onTap: () => Navigator.of(context).pop(),
                          text: 'Comenzar',
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