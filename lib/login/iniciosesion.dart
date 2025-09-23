import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'registrarse.dart';
import 'recuperar.dart';
import '../pantallas/principal.dart';

/// 🚀 PANTALLA DE INICIO DE SESIÓN PREMIUM - SOCCER LIFE
/// 
/// Login ultra-moderno con animaciones, glassmorphism y efectos premium
/// Diseño inspirado en las mejores apps del mundo con micro-interacciones
/// y elementos visuales que impresionan desde el primer momento.
/// 
/// ✨ Características Premium:
/// - Animaciones fluidas y naturales
/// - Glassmorphism y efectos de cristal
/// - Gradientes dinámicos animados
/// - Micro-interacciones en cada elemento
/// - Feedback visual inmediato
/// - Transiciones cinematográficas
class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage>
    with TickerProviderStateMixin {
  // ===== 🎬 CONTROLADORES DE ANIMACIÓN =====
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // ===== 📝 CONTROLADORES DE FORMULARIO =====
  
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  // ===== 🎛️ ESTADOS DE LA INTERFAZ =====
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _emailFocused = false;
  bool _passwordFocused = false;

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




  }

  /// 🎯 Configurar listeners para efectos de focus
  void _setupFocusListeners() {
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
  }

  /// 🚀 Iniciar animaciones de entrada
  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  // ===== 🧹 LIMPIEZA DE RECURSOS =====
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ===== 🔐 LÓGICA DE AUTENTICACIÓN PREMIUM =====
  
  /// Maneja el login con animaciones y feedback visual premium
  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      // Haptic feedback para sensación premium
      HapticFeedback.lightImpact();
      
      // Simular proceso de autenticación
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        // Feedback de éxito con vibración
        HapticFeedback.mediumImpact();
        
        // SnackBar premium con gradiente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '¡Bienvenido de vuelta!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Iniciando tu experiencia futbolística...',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
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
        
        // Navegación con transición premium
        await Future.delayed(const Duration(milliseconds: 800));
        
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => const PrincipalPage(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOutCubicEmphasized;
                
                var tween = Tween(begin: begin, end: end).chain(
                  CurveTween(curve: curve),
                );
                
                return SlideTransition(
                  position: animation.drive(tween),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              transitionDuration: const Duration(milliseconds: 800),
            ),
            (route) => false,
          );
        }
      }
      
      setState(() => _isLoading = false);
    } else {
      // Feedback de error
      HapticFeedback.heavyImpact();
    }
  }

  // ===== 🎨 CONSTRUCCIÓN DE LA INTERFAZ PREMIUM =====
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              children: [
                // ===== 🏟️ FONDO DE IMAGEN DE FÚTBOL =====
                _buildFootballBackground(),
                
                // ===== CONTENIDO PRINCIPAL =====
                SafeArea(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // ===== HEADER PREMIUM CON LOGO ANIMADO =====
                        SliverToBoxAdapter(
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildPremiumHeader(),
                          ),
                        ),
                        
                        // ===== FORMULARIO GLASSMORPHISM =====
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildGlassmorphismCard(),
                                  const SizedBox(height: 32),
                                  _buildRegisterSection(),
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

  // ===== �️ FONDO CON IMAGEN DE FÚTBOL =====
  
  /// Crea un fondo espectacular con imagen real de campo de fútbol
  Widget _buildFootballBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          // 🏆 USANDO TU IMAGEN PERSONALIZADA: championsfondo.png
          image: AssetImage('images/championsfondo.png'),
          
          // 🔥 OTRAS OPCIONES (descomenta para cambiar):
          // Opción 1: Campo de fútbol profesional
          // image: NetworkImage('https://images.unsplash.com/photo-1551698618-1dfe5d97d256?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80'),
          
          // Opción 2: Estadio épico 
          // image: NetworkImage('https://images.unsplash.com/photo-1508098682722-e99c43a406b2?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80'),
          
          // Opción 3: Campo con luces nocturnas
          // image: NetworkImage('https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?ixlib=rb-4.0.3&auto=format&fit=crop&w=2000&q=80'),
          
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // 🎨 Overlay SÚPER ligero para que se vea tu imagen de fondo
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.2), // Muy transparente arriba
              Colors.black.withOpacity(0.1), // Casi transparente en medio  
              Colors.black.withOpacity(0.3), // Un poco más oscuro abajo
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
    return Container(
      height: 280,
      child: Stack(
        children: [
          // Contenido principal del header limpio
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo limpio y redondito flotando sobre tu imagen
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
                
                // Título limpio y profesional
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
                    'Tu Evolución Futbolística',
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
          ),
        ],
      ),
    );
  }



  // ===== 🎯 FORMULARIO FLOTANTE DIRECTO =====
  
  /// Campos flotando directamente sobre tu imagen championsfondo.png
  Widget _buildGlassmorphismCard() {
    return Container(
      // 🔥 SIN DECORACIÓN - Solo los campos flotando sobre tu imagen
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
                children: [
                  // Título del formulario
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFF00f5ff)],
                    ).createShader(bounds),
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                        // 🎯 Sombra para que se vea bien sobre tu imagen de fondo
                        shadows: [
                          Shadow(
                            offset: const Offset(2, 2),
                            blurRadius: 8,
                            color: Colors.black.withOpacity(0.8),
                          ),
                          Shadow(
                            offset: const Offset(-1, -1),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Campo de email 
                  _buildPremiumTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Correo electrónico',
                    hint: 'tu@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    isFocused: _emailFocused,
                    onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Ingresa tu correo electrónico';
                      }
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                        return 'Ingresa un correo electrónico válido';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Campo de contraseña 
                  _buildPremiumTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    isFocused: _passwordFocused,
                    onFieldSubmitted: (_) => _login(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                        HapticFeedback.selectionClick();
                      },
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Botón de ingresar
                  _buildPremiumButton(),
                  
                  const SizedBox(height: 20),
                  
                  // Enlace de recuperar
                  TextButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => const RecuperarPasswordPage(),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(opacity: animation, child: child);
                          },
                        ),
                      );
                    },
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  // ===== ✨ CAMPO DE TEXTO PREMIUM =====
  
  /// Crea campos de texto con efectos premium y animaciones
  Widget _buildPremiumTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    void Function(String)? onFieldSubmitted,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFocused 
            ? const Color(0xFF00f5ff).withOpacity(0.8)
            : Colors.white.withOpacity(0.3),
          width: isFocused ? 2 : 1,
        ),
        gradient: LinearGradient(
          colors: [
            // 🔥 Campos flotantes súper elegantes sobre tu imagen
            Colors.black.withOpacity(isFocused ? 0.3 : 0.2), // Fondo oscuro sutil
            Colors.black.withOpacity(isFocused ? 0.25 : 0.15), // Para contraste con texto blanco
          ],
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        obscureText: obscureText,
        onFieldSubmitted: onFieldSubmitted,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
          suffixIcon: suffixIcon,
          labelStyle: TextStyle(
            color: isFocused ? const Color(0xFF00f5ff) : Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          errorStyle: const TextStyle(
            color: Color(0xFFff6b6b),
            fontWeight: FontWeight.w500,
          ),
        ),
        validator: validator,
      ),
    );
  }

  // ===== 🚀 BOTÓN PREMIUM CON GRADIENTE =====
  
  /// Botón de login con efectos premium y carga animada
  Widget _buildPremiumButton() {
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
            Color(0xFF00f5ff),
            Color(0xFF00d4aa),
            Color(0xFF00a8cc),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _login,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Ingresar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== 🎨 SECCIÓN DE REGISTRO PREMIUM =====
  
  /// Botón de registro con diseño glassmorphism
  Widget _buildRegisterSection() {
    return Container(
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
            HapticFeedback.selectionClick();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const RegistrarsePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                    child: child,
                  );
                },
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_add_outlined,
                  color: Colors.white.withOpacity(0.8),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Crear cuenta nueva',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
