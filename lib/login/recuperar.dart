import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

/// 🚀 PANTALLA DE RECUPERAR CONTRASEÑA PREMIUM - SOCCER LIFE
/// 
/// Recuperación ultra-moderna con animaciones, glassmorphism y efectos premium
/// Diseño consistente con las pantallas de login y registro para una experiencia
/// cohesiva y profesional. Con el mismo fondo espectacular de championsfondo.png
/// 
/// ✨ Características Premium:
/// - Animaciones fluidas y naturales
/// - Glassmorphism y efectos de cristal
/// - Gradientes dinámicos animados
/// - Micro-interacciones en cada elemento
/// - Feedback visual inmediato
/// - Transiciones cinematográficas
/// - Pantalla de éxito espectacular
class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage>
    with TickerProviderStateMixin {
  // ===== 🎬 CONTROLADORES DE ANIMACIÓN =====
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // ===== 📝 CONTROLADORES DE FORMULARIO =====
  
  final _formKey = GlobalKey<FormState>();
  final _codigoFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final List<TextEditingController> _codigoControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _codigoFocusNodes = List.generate(6, (index) => FocusNode());
  final _emailFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  
  // ===== 🎛️ ESTADOS DE LA INTERFAZ =====
  
  String _metodoSeleccionado = 'email';
  bool _codigoEnviado = false;
  bool _enviando = false;
  bool _verificando = false;
  bool _emailFocused = false;
  bool _telefonoFocused = false;
  bool _recuperacionExitosa = false;
  String _codigoGenerado = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
    _startEntryAnimation();
  }

  /// 🎨 Inicializar animaciones esenciales
  void _initializeAnimations() {
    // Animación de fade para la entrada general
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Animación de slide para elementos
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    // Animación de escala para efectos especiales
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  /// 🎯 Configurar listeners para efectos de focus
  void _setupFocusListeners() {
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _telefonoFocus.addListener(() {
      setState(() => _telefonoFocused = _telefonoFocus.hasFocus);
    });
  }

  /// 🚀 Iniciar animaciones de entrada
  void _startEntryAnimation() {
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
    _emailController.dispose();
    _telefonoController.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    for (var controller in _codigoControllers) {
      controller.dispose();
    }
    for (var focusNode in _codigoFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // ===== 🔐 LÓGICA DE RECUPERACIÓN PREMIUM =====
  
  /// Envía código de verificación con animaciones y feedback premium
  Future<void> _enviarCodigoVerificacion() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _enviando = true);
      
      // Haptic feedback para sensación premium
      HapticFeedback.lightImpact();
      
      // Simular proceso de envío
      await Future.delayed(const Duration(milliseconds: 2000));
      
      // Generar código de 6 dígitos
      _codigoGenerado = (100000 + (900000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).floor().toString();
      
      if (mounted) {
        setState(() {
          _enviando = false;
          _codigoEnviado = true;
        });
        
        // Feedback de éxito con vibración
        HapticFeedback.mediumImpact();
        
        // SnackBar premium con gradiente
        final destino = _metodoSeleccionado == 'email' ? _emailController.text : _telefonoController.text;
        final metodo = _metodoSeleccionado == 'email' ? 'correo' : 'SMS';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00b4db), Color(0xFF0083b0)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '¡Código enviado exitosamente!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Código $_codigoGenerado enviado por $metodo a $destino',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  /// Verificar código con animaciones y feedback premium
  Future<void> _verificarCodigo() async {
    final codigoIngresado = _codigoControllers.map((c) => c.text).join();
    
    if (codigoIngresado.length == 6) {
      setState(() => _verificando = true);
      
      // Haptic feedback
      HapticFeedback.lightImpact();
      
      // Simular verificación
      await Future.delayed(const Duration(milliseconds: 1500));
      
      setState(() => _verificando = false);

      if (mounted) {
        if (codigoIngresado == _codigoGenerado) {
          // Código correcto - mostrar pantalla de éxito
          HapticFeedback.mediumImpact();
          
          setState(() => _recuperacionExitosa = true);
          
          // Iniciar animación de éxito
          _scaleController.reset();
          _scaleController.forward();
        } else {
          // Código incorrecto - mostrar error premium
          HapticFeedback.heavyImpact();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFe74c3c), Color(0xFFc0392b)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error, color: Colors.white, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Código incorrecto',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Inténtalo de nuevo o reenvía el código',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Limpiar campos y enfocar
          for (var controller in _codigoControllers) {
            controller.clear();
          }
          _codigoFocusNodes[0].requestFocus();
        }
      }
    }
  }

  /// Regresar a la pantalla anterior con haptic feedback
  void _regresarLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  // ===== 🔍 VALIDADORES PREMIUM =====
  
  /// Valida el formato del correo electrónico
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  /// Valida el formato del número de teléfono
  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return 'El teléfono es obligatorio';
    if (value.length < 10) return 'El número debe tener 10 dígitos';
    return null;
  }

  // ===== 🎨 CONSTRUCCIÓN DE LA INTERFAZ PREMIUM =====
  
  @override
  Widget build(BuildContext context) {
    // Si la recuperación fue exitosa, mostrar pantalla de éxito
    if (_recuperacionExitosa) {
      return _buildSuccessScreen();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: _regresarLogin,
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
                // ===== 🏆 FONDO CON IMAGEN DE FÚTBOL =====
                _buildFootballBackground(),
                
                // ===== 📱 CONTENIDO PRINCIPAL =====
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),
                        
                        // ===== ⚽ HEADER PREMIUM FUTBOLÍSTICO =====
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildPremiumHeader(),
                        ),
                        
                        const SizedBox(height: 50),
                        
                        // ===== 🎯 FORMULARIO FLOTANTE =====
                        SlideTransition(
                          position: _slideAnimation,
                          child: _codigoEnviado 
                            ? _buildVerificationScreen()
                            : _buildRecoveryForm(),
                        ),
                        
                        const SizedBox(height: 30),
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

  // ===== 🏆 FONDO CON IMAGEN DE FÚTBOL =====
  
  /// Crea un fondo espectacular con la imagen de championsfondo.png
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
              Colors.black.withOpacity(0.1),
              Colors.black.withOpacity(0.2),
              Colors.black.withOpacity(0.3),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }

  // ===== ⚽ HEADER PREMIUM FUTBOLÍSTICO =====
  
  /// Header espectacular con logo y elementos temáticos de fútbol
  Widget _buildPremiumHeader() {
    return SizedBox(
      height: 200,
      child: Column(
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
          
          // Título limpio y profesional (IGUAL QUE INICIO DE SESIÓN)
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
          
          const SizedBox(height: 12),
          
          // Subtítulo elegante y limpio (IGUAL QUE INICIO DE SESIÓN)
          Center(
            child: Text(
              'Recuperar Contraseña',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== 🎨 WIDGETS PREMIUM REUTILIZABLES =====
  
  /// Selector de método premium con glassmorphism
  Widget _buildMethodSelector() {
    return Row(
      children: [
        // Opción Email
        Expanded(
          child: _buildMethodOption(
            icon: Icons.email_outlined,
            label: 'Email',
            isSelected: _metodoSeleccionado == 'email',
            onTap: () => setState(() => _metodoSeleccionado = 'email'),
          ),
        ),
        const SizedBox(width: 16),
        // Opción SMS
        Expanded(
          child: _buildMethodOption(
            icon: Icons.sms_outlined,
            label: 'SMS',
            isSelected: _metodoSeleccionado == 'sms',
            onTap: () => setState(() => _metodoSeleccionado = 'sms'),
          ),
        ),
      ],
    );
  }

  /// Opción individual del selector de método
  Widget _buildMethodOption({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                  ? const Color(0xFF00b4db) 
                  : Colors.white.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              gradient: LinearGradient(
                colors: isSelected 
                  ? [
                      const Color(0xFF00b4db).withOpacity(0.2),
                      const Color(0xFF0083b0).withOpacity(0.1),
                    ]
                  : [
                      Colors.white.withOpacity(0.1),
                      Colors.white.withOpacity(0.05),
                    ],
              ),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected 
                    ? const Color(0xFF00b4db) 
                    : Colors.white.withOpacity(0.7),
                  size: 32,
                ),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                      ? const Color(0xFF00b4db) 
                      : Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Campo de texto premium con glassmorphism
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused 
            ? const Color(0xFF00b4db)
            : Colors.white.withOpacity(0.3),
          width: isFocused ? 2 : 1,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(isFocused ? 0.15 : 0.1),
            Colors.black.withOpacity(isFocused ? 0.25 : 0.15),
          ],
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: const Color(0xFF00b4db).withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          labelStyle: TextStyle(
            color: isFocused ? const Color(0xFF00b4db) : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          errorStyle: const TextStyle(
            color: Color(0xFFe74c3c),
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: validator,
      ),
    );
  }

  /// Botón premium con gradiente y efectos
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00b4db),
            Color(0xFF0083b0),
            Color(0xFF00a8cc),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00b4db).withOpacity(0.4),
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
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Center(
              child: isLoading
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Enviando...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                : Text(
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

  // ===== 🎯 FORMULARIO DE RECUPERACIÓN PREMIUM =====
  
  /// Formulario flotante para seleccionar método de recuperación
  Widget _buildRecoveryForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Explicación del proceso con glassmorphism
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    color: Color(0xFF00b4db),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Selecciona cómo quieres recibir tu código de verificación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Selección de método premium
            _buildMethodSelector(),
            
            const SizedBox(height: 24),
            
            // Campo dinámico según método seleccionado
            _metodoSeleccionado == 'email'
              ? _buildPremiumTextField(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  label: 'Correo Electrónico',
                  hint: 'tu@email.com',
                  icon: Icons.email_outlined,
                  isFocused: _emailFocused,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                )
              : _buildPremiumTextField(
                  controller: _telefonoController,
                  focusNode: _telefonoFocus,
                  label: 'Número de Celular',
                  hint: '3001234567',
                  icon: Icons.phone_outlined,
                  isFocused: _telefonoFocused,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                ),
            
            const SizedBox(height: 32),
            
            // Botón de enviar código
            _buildPremiumButton(
              onTap: _enviando ? null : _enviarCodigoVerificacion,
              text: 'Enviar código por ${_metodoSeleccionado == 'email' ? 'correo' : 'SMS'}',
              isLoading: _enviando,
            ),
          ],
        ),
      ),
    );
  }

  // ===== 📱 PANTALLA DE VERIFICACIÓN PREMIUM =====
  
  /// Pantalla de verificación de código con diseño premium
  Widget _buildVerificationScreen() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _codigoFormKey,
        child: Column(
          children: [
            // Icono de verificación con glassmorphism
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00b4db).withOpacity(0.2),
                    const Color(0xFF0083b0).withOpacity(0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                size: 48,
                color: Color(0xFF00b4db),
              ),
            ),

            const SizedBox(height: 32),

            // Título de verificación con gradiente
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF00b4db), Color(0xFF0083b0)],
              ).createShader(bounds),
              child: const Text(
                'Verificar Código',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Información del envío con glassmorphism
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Código enviado por ${_metodoSeleccionado == 'email' ? 'correo a:' : 'SMS a:'}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _metodoSeleccionado == 'email' ? _emailController.text : _telefonoController.text,
                    style: const TextStyle(
                      color: Color(0xFF00b4db),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Título para los campos del código
            const Text(
              'Ingresa el código de 6 dígitos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),

            // Campos para el código de 6 dígitos con glassmorphism
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 45,
                  height: 55,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.black.withOpacity(0.15),
                        ],
                      ),
                    ),
                    child: TextFormField(
                      controller: _codigoControllers[index],
                      focusNode: _codigoFocusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      onChanged: (value) {
                        // Auto-focus al siguiente campo cuando se ingresa un dígito
                        if (value.isNotEmpty && index < 5) {
                          _codigoFocusNodes[index + 1].requestFocus();
                        }
                        // Auto-verificar cuando se completan los 6 dígitos
                        if (index == 5 && value.isNotEmpty) {
                          _verificarCodigo();
                        }
                      },
                      onTap: () {
                        // Seleccionar todo el texto al hacer tap
                        _codigoControllers[index].selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _codigoControllers[index].text.length,
                        );
                      },
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // Botón de verificar
            _buildPremiumButton(
              onTap: _verificando ? null : _verificarCodigo,
              text: 'Verificar código',
              isLoading: _verificando,
            ),

            const SizedBox(height: 24),

            // Botón de reenviar código con glassmorphism
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.1),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _codigoEnviado = false;
                      // Limpiar campos del código
                      for (var controller in _codigoControllers) {
                        controller.clear();
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh,
                          color: Colors.white.withOpacity(0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reenviar código',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===== 🎉 PANTALLA DE ÉXITO ESPECTACULAR =====
  
  /// Pantalla de éxito con animaciones y confetti
  Widget _buildSuccessScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fondo con imagen
          _buildFootballBackground(),
          
          // Contenido de éxito
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                margin: const EdgeInsets.all(32),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ícono de éxito con gradiente
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
                            color: const Color(0xFF2ecc71).withOpacity(0.4),
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
                    
                    // Título de éxito
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                      ).createShader(bounds),
                      child: const Text(
                        '¡Código Verificado!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Descripción
                    Text(
                      'Tu identidad ha sido verificada exitosamente. Ahora puedes crear una nueva contraseña.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de continuar
                    _buildPremiumButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Navigator.of(context).pop();
                        // Aquí navegarías a la pantalla de nueva contraseña
                      },
                      text: 'Crear Nueva Contraseña',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botón secundario para volver al login
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
