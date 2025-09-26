import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registrarse.dart';
import 'recuperar.dart';
import '../pantallas/principal.dart';

/// Pantalla de inicio de sesión de Soccer Life
/// Permite a los usuarios autenticarse en la aplicación con su email y contraseña
class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage>
    with TickerProviderStateMixin {
  
  // Controladores para las animaciones de entrada suave
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controladores para el formulario de login
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  
  // Estados de la interfaz para controlar la visibilidad y efectos
  bool _obscurePassword = true; // Ocultar/mostrar contraseña
  bool _isLoading = false; // Estado de carga durante el login
  bool _emailFocused = false; // Si el campo email está enfocado
  bool _passwordFocused = false; // Si el campo contraseña está enfocado

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFocusListeners();
    _startEntryAnimation();
  }

  /// Configura las animaciones que se ejecutan cuando se carga la pantalla
  void _initializeAnimations() {
    // Animación que hace aparecer gradualmente todos los elementos
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );

    // Animación que desliza los elementos desde abajo hacia arriba
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));
  }

  /// Escucha cuando los campos de texto reciben o pierden el foco para cambiar su estilo
  void _setupFocusListeners() {
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    _passwordFocus.addListener(() {
      setState(() => _passwordFocused = _passwordFocus.hasFocus);
    });
  }

  /// Ejecuta las animaciones de entrada con un pequeño retraso
  void _startEntryAnimation() {
    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  /// Libera todos los recursos cuando se destruye la pantalla para evitar fugas de memoria
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

  /// Procesa el inicio de sesión del usuario
  /// Valida los datos, simula la autenticación y navega a la pantalla principal
  Future<void> _login() async {
    // Solo proceder si el formulario es válido
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      
      // Simular llamada al servidor (en producción sería una API real)
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (mounted) {
        setState(() => _isLoading = false);
        
        // Navegar a la pantalla principal y limpiar el historial de navegación
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PrincipalPage()),
          (route) => false,
        );
      }
    }
  }

  /// Construye la interfaz principal de la pantalla de login
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
                // Fondo con imagen del estadio de fútbol
                _buildFootballBackground(),
                
                // Contenido principal de la pantalla
                SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Encabezado con logo y título de la app
                      SliverToBoxAdapter(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildHeader(),
                        ),
                      ),
                      
                      // Formulario de login y botón de registro
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildLoginForm(),
                                const SizedBox(height: 32),
                                _buildRegisterButton(),
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

  /// Crea el fondo de la pantalla con la imagen del estadio y un overlay oscuro sutil
  Widget _buildFootballBackground() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/championsfondo.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Overlay oscuro muy ligero para mejorar la legibilidad del texto
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
            // Un poco más oscuro abajo
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
      ),
    );
  }



  /// Construye el encabezado con el logo de Soccer Life y el título principal
  Widget _buildHeader() {
    return Container(
      height: 280,
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo de la aplicación con sombra
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(60),
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
                
                // Nombre de la aplicación
                Text(
                  'Soccer Life',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF00f5ff),
                    letterSpacing: 2,
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
                
                const SizedBox(height: 8),
                
                // Eslogan de la aplicación
                Text(
                  'Tu Evolución Futbolística',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }



  /// Construye el formulario de login con los campos de email y contraseña
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Título del formulario de login
            Text(
              'Iniciar Sesión',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF00f5ff),
                letterSpacing: 1,
                // Sombra para que se vea bien sobre la imagen de fondo
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
            
            const SizedBox(height: 32),
            
            // Campo para ingresar el email
            _buildTextField(
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
            
            // Campo para ingresar la contraseña
            _buildTextField(
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
                return null;
              },
            ),
            
            const SizedBox(height: 32),
            
            // Botón principal para iniciar sesión
            _buildLoginButton(),
            
            const SizedBox(height: 20),
            
            // Enlace para recuperar contraseña olvidada
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

  /// Crea un campo de texto personalizado con estilo moderno y efectos visuales
  Widget _buildTextField({
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
            Colors.black.withOpacity(isFocused ? 0.3 : 0.2), 
            Colors.black.withOpacity(isFocused ? 0.25 : 0.15),
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

  /// Construye el botón principal de login con gradiente y animación de carga
  Widget _buildLoginButton() {
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

  /// Construye el botón que permite navegar a la pantalla de registro
  Widget _buildRegisterButton() {
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
