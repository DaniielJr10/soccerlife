import 'package:flutter/material.dart';
import 'registrarse.dart';
import 'recuperar.dart';
import '../pantallas/principal.dart';

/// Pantalla de inicio de sesión de Soccer Life
/// 
/// Esta pantalla permite a los usuarios autenticarse en la aplicación.
/// Incluye validación de formularios, navegación a otras pantallas relacionadas
/// con la autenticación y una interfaz moderna con gradientes.
/// 
/// Características principales:
/// - Formulario de login con validación
/// - Navegación a registro y recuperación de contraseña
/// - Diseño responsivo con gradientes
/// - Manejo de estados del formulario
class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  // ===== CONTROLADORES Y ESTADO DEL FORMULARIO =====
  
  /// Key para validación del formulario
  final _formKey = GlobalKey<FormState>();
  
  /// Controlador para el campo de email
  final _emailController = TextEditingController();
  
  /// Controlador para el campo de contraseña
  final _passwordController = TextEditingController();
  
  /// Nodo de foco para el campo de email
  final _emailFocus = FocusNode();
  
  /// Nodo de foco para el campo de contraseña
  final _passwordFocus = FocusNode();
  
  /// Estado para mostrar/ocultar la contraseña
  bool _obscure = true;

  // ===== LIMPIEZA DE RECURSOS =====
  
  @override
  void dispose() {
    // Liberar recursos de controladores y focos cuando la pantalla se destruye
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ===== LÓGICA DE AUTENTICACIÓN =====
  
  /// Maneja el proceso de inicio de sesión
  /// Valida el formulario y navega a la pantalla principal si es exitoso
  void _login() {
    // Validar que todos los campos estén correctos
    if (_formKey.currentState?.validate() ?? false) {
      // Mostrar mensaje de éxito al usuario
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Inicio de sesión exitoso!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      // Navegar a la pantalla principal y limpiar el historial de navegación
      // Esto previene que el usuario pueda regresar al login con el botón atrás
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const PrincipalPage()),
        (route) => false,
      );
    }
  }

  // ===== CONSTRUCCIÓN DE LA INTERFAZ =====
  
  @override
  Widget build(BuildContext context) {
    // Obtener tema y definir color principal para consistencia visual
    final theme = Theme.of(context);
    final primary = Colors.green.shade800;

    return Scaffold(
      // Evitar que el teclado empuje el contenido fuera de la pantalla
      resizeToAvoidBottomInset: true,
      body: Container(
        // ===== FONDO CON GRADIENTE =====
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE9F5EE), // Verde muy claro
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          // ===== LAYOUT RESPONSIVO =====
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Padding horizontal y vertical para márgenes
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  // Asegurar que el contenido ocupe al menos toda la altura disponible
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 32 ? constraints.maxHeight - 32 : 0
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== SECCIÓN DE ENCABEZADO =====
                        _buildHeader(theme),
                        
                        const SizedBox(height: 28),
                        
                        // ===== SECCIÓN DE FORMULARIO =====
                        _buildLoginForm(theme, primary),
                        
                        const SizedBox(height: 50),
                        
                        // ===== SECCIÓN DE REGISTRO =====
                        _buildRegisterSection(primary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===== CONSTRUCCIÓN DEL ENCABEZADO =====
  
  /// Construye la sección del encabezado con logo y títulos
  /// Incluye el logo de la app, título principal y subtítulo
  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // Espacio superior
        const SizedBox(height: 50),
        
        // Logo de la aplicación
        Align(
          child: Image.asset(
            'images/logo.png',
            width: 90,
            height: 90,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        
        // Título principal de la app
        Text(
          'Soccer Life',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.green.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        
        // Subtítulo descriptivo
        Text(
          'Tu evolución futbolística',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ===== CONSTRUCCIÓN DEL FORMULARIO DE LOGIN =====
  
  /// Construye el formulario de inicio de sesión
  /// Incluye campos de email y contraseña con validación
  Widget _buildLoginForm(ThemeData theme, Color primary) {
    return Form(
      key: _formKey,
      // Validación automática después de la primera interacción
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título del formulario
          Text(
            'Iniciar Sesión',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 27),
          
          // ===== CAMPO DE EMAIL =====
          TextFormField(
            controller: _emailController,
            focusNode: _emailFocus,
            textInputAction: TextInputAction.next,
            // Al presionar "siguiente" enfoca el campo de contraseña
            onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: 'Correo electrónico',
              hintText: 'tu@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            // Validación del email
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Ingresa tu correo electrónico';
              }
              // Expresión regular para validar formato de email
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                return 'Ingresa un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 30),
          
          // ===== CAMPO DE CONTRASEÑA =====
          TextFormField(
            controller: _passwordController,
            focusNode: _passwordFocus,
            textInputAction: TextInputAction.done,
            // Al presionar "listo" ejecuta el login
            onFieldSubmitted: (_) => _login(),
            obscureText: _obscure, // Ocultar/mostrar contraseña
            decoration: InputDecoration(
              labelText: 'Contraseña',
              prefixIcon: const Icon(Icons.lock_outline),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              // Botón para mostrar/ocultar contraseña
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Mostrar contraseña' : 'Ocultar contraseña',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
              ),
            ),
            // Validación de la contraseña
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
          const SizedBox(height: 23),
          
          // ===== BOTÓN DE INGRESAR =====
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _login,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Ingresar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // ===== ENLACE DE RECUPERAR CONTRASEÑA =====
          Center(
            child: TextButton(
              onPressed: () {
                // Navegar a la pantalla de recuperación de contraseña
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RecuperarPasswordPage(),
                  ),
                );
              },
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===== CONSTRUCCIÓN DE LA SECCIÓN DE REGISTRO =====
  
  /// Construye la sección inferior para crear cuenta nueva
  /// Incluye botón para navegar al registro
  Widget _buildRegisterSection(Color primary) {
    return Padding(
      padding: const EdgeInsets.only(top: 0),
      child: SizedBox(
        height: 50,
        child: OutlinedButton(
          onPressed: () {
            // Navegar a la pantalla de registro
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const RegistrarsePage(),
              ),
            );
          },
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: primary, width: 1.5),
            foregroundColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Crear cuenta nueva',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
