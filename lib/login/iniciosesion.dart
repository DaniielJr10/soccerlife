import 'package:flutter/material.dart';

// Pantalla de Login de Soccer Life
// Este archivo define la UI y la lógica básica de validación/UX del formulario
// (email, contraseña, mostrar/ocultar, focos y botones de acciones). Todo está
// distribuido a pantalla completa (encabezado, formulario y acción inferior).

/// Pantalla de inicio de sesión inspirada en el diseño de la imagen adjunta.
class InicioSesionPage extends StatefulWidget {
  const InicioSesionPage({super.key});

  @override
  State<InicioSesionPage> createState() => _InicioSesionPageState();
}

class _InicioSesionPageState extends State<InicioSesionPage> {
  // Estado y controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _obscure = true;

  @override
  void dispose() {
  // Liberar recursos de controladores y focos cuando la pantalla se destruye
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _login() {
  // Acción de login (placeholder). Si la validación pasa, muestra SnackBar.
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Iniciando sesión...')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
  // Tema y color principal reutilizados en varios widgets
  final theme = Theme.of(context);
  final primary = Colors.green.shade800;

    return Scaffold(
      // Evitar solapamiento con el teclado en pantallas pequeñas
      resizeToAvoidBottomInset: true,
      body: Container(
        // Fondo con gradiente suave (verde muy claro a blanco)
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFE9F5EE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          // LayoutBuilder para distribuir verticalmente el contenido según alto disponible
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                // Scroll para evitar overflow con teclado
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  // Asegurarnos de ocupar toda la altura visible
                  constraints: BoxConstraints(minHeight: constraints.maxHeight > 32 ? constraints.maxHeight - 32 : 0),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      // Cambiar la distribución para más control manual
                      children: [
                        // ===== Encabezado =====
                        Column(
                          children: [
                            // Logo de la app
                            const SizedBox(height: 50),
                            Align(
                              child: Image.asset(
                                'images/logo.png',
                                width: 90,
                                height: 90,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Título y subtítulo
                            Text(
                              'Soccer Life',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tu evolución futbolística',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.black54,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        // Espacio entre encabezado y formulario
                        const SizedBox(height: 28),

                        // ===== Formulario =====
                        Form(
                          // Validación en vivo tras interacción
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Encabezado del formulario
                              Text(
                                'Iniciar Sesión',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 27),
                              // Campo de email
                              TextFormField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                textInputAction: TextInputAction.next,
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
                                // Reglas básicas de validación de email
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                                    return 'Correo inválido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 30),
                              // Campo de contraseña con botón de mostrar/ocultar
                              TextFormField(
                                controller: _passwordController,
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _login(),
                                obscureText: _obscure,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure ? 'Mostrar' : 'Ocultar',
                                    onPressed: () => setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                // Reglas básicas de validación de contraseña
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
                                  if (v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 23),
                              // Botón principal de ingresar
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
                                  child: const Text('Ingresar'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Enlace de recuperación de contraseña
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Recuperar contraseña')),
                                    );
                                  },
                                  child: const Text('¿Olvidaste tu contraseña?'),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Espacio flexible reducido
                        const SizedBox(height: 50),

                        // ===== Acción inferior (Crear cuenta) =====
                        // Se muestra siempre al final para invitar al registro
                        Padding(
                          padding: const EdgeInsets.only(top: 0),
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Ir a crear cuenta')),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primary, width: 1.5),
                                foregroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Crear cuenta'),
                            ),
                          ),
                        ),
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
}
