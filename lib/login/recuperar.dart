import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pantalla de Recuperación de Contraseña de Soccer Life
// Este archivo define la UI y la lógica para el proceso de recuperación de contraseña.
// Permite al usuario elegir entre recibir un código por email o SMS.
// Envía un código de verificación de 6 dígitos al método seleccionado.
// Incluye pantalla de verificación de código con campos individuales.

/// Pantalla de recuperación de contraseña que permite al usuario recibir
/// un código de verificación por email o número de celular.
class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage> {
  // ===== Controladores y estado del formulario =====
  // FormKey para validación del formulario
  final _formKey = GlobalKey<FormState>();
  // FormKey para validación del código
  final _codigoFormKey = GlobalKey<FormState>();
  // Controlador para el campo de email
  final _emailController = TextEditingController();
  // Controlador para el campo de teléfono
  final _telefonoController = TextEditingController();
  // Controladores para los 6 campos del código
  final List<TextEditingController> _codigoControllers = List.generate(6, (index) => TextEditingController());
  // Nodos de foco para los campos del código
  final List<FocusNode> _codigoFocusNodes = List.generate(6, (index) => FocusNode());
  // Nodo de foco para el campo de email
  final _emailFocus = FocusNode();
  // Nodo de foco para el campo de teléfono
  final _telefonoFocus = FocusNode();
  // Método seleccionado para envío (email o sms)
  String _metodoSeleccionado = 'email';
  // Estado para mostrar si el código fue enviado
  bool _codigoEnviado = false;
  // Estado para mostrar loading durante el envío
  bool _enviando = false;
  // Estado para mostrar loading durante verificación
  bool _verificando = false;
  // Código generado (para simulación)
  String _codigoGenerado = '';

  @override
  void dispose() {
    // Liberar recursos de controladores y focos cuando la pantalla se destruye
    _emailController.dispose();
    _telefonoController.dispose();
    _emailFocus.dispose();
    _telefonoFocus.dispose();
    // Liberar recursos de los controladores del código
    for (var controller in _codigoControllers) {
      controller.dispose();
    }
    for (var focusNode in _codigoFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // ===== Función para enviar código de verificación =====
  void _enviarCodigoVerificacion() async {
    // Validar que el formulario esté correcto antes de proceder
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _enviando = true;
      });

      // Simular delay de envío de código (en una app real aquí iría la llamada al API)
      await Future.delayed(const Duration(seconds: 2));

      // Generar código aleatorio de 6 dígitos para mostrar al usuario
      _codigoGenerado = (100000 + (900000 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000)).floor().toString();

      setState(() {
        _enviando = false;
        _codigoEnviado = true;
      });

      // Mostrar confirmación al usuario con el código enviado
      if (mounted) {
        final destino = _metodoSeleccionado == 'email' 
            ? _emailController.text 
            : _telefonoController.text;
        final metodo = _metodoSeleccionado == 'email' ? 'correo' : 'SMS';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Código $_codigoGenerado enviado por $metodo a $destino'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  // ===== Función para verificar el código ingresado =====
  void _verificarCodigo() async {
    // Construir código completo desde los 6 campos
    final codigoIngresado = _codigoControllers.map((c) => c.text).join();
    
    if (codigoIngresado.length == 6) {
      setState(() {
        _verificando = true;
      });

      // Simular verificación del código
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _verificando = false;
      });

      if (mounted) {
        if (codigoIngresado == _codigoGenerado) {
          // Código correcto - mostrar éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Código verificado! Redirigiendo...'),
              backgroundColor: Colors.green,
            ),
          );
          // Aquí podrías navegar a la pantalla de nueva contraseña
        } else {
          // Código incorrecto - mostrar error
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Código incorrecto. Inténtalo de nuevo.'),
              backgroundColor: Colors.red,
            ),
          );
          // Limpiar campos del código
          for (var controller in _codigoControllers) {
            controller.clear();
          }
          _codigoFocusNodes[0].requestFocus();
        }
      }
    }
  }

  // ===== Función para regresar a la pantalla anterior =====
  void _regresarLogin() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    // ===== Configuración de tema y colores =====
    final theme = Theme.of(context);
    final primary = Colors.green.shade800;

    return Scaffold(
      // Evitar solapamiento con el teclado en pantallas pequeñas
      resizeToAvoidBottomInset: true,
      body: Container(
        // ===== Fondo con gradiente suave =====
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
          // ===== Layout principal con scroll para evitar overflow =====
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  // Asegurar que ocupe toda la altura disponible
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 32 ? constraints.maxHeight - 32 : 0
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ===== Encabezado con botón de regreso =====
                        Row(
                          children: [
                            // Botón de regreso a la pantalla anterior
                            IconButton(
                              onPressed: _regresarLogin,
                              icon: const Icon(Icons.arrow_back_ios),
                              tooltip: 'Regresar',
                            ),
                            const Spacer(),
                          ],
                        ),

                        // ===== Logo y título de la aplicación =====
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            // Logo de la aplicación
                            Align(
                              child: Image.asset(
                                'images/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Título principal
                            Text(
                              'Soccer Life',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtítulo descriptivo de la pantalla
                            Text(
                              'Recuperar contraseña',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // ===== Contenido principal condicional =====
                        // Mostrar diferentes contenidos según el estado del proceso
                        if (!_codigoEnviado) ...[
                          // ===== Formulario de recuperación =====
                          _buildFormularioRecuperacion(theme, primary),
                        ] else ...[
                          // ===== Pantalla de verificación de código =====
                          _buildPantallaVerificacion(theme, primary),
                        ],

                        // Espacio flexible para empujar el contenido inferior
                        const Spacer(),

                        // ===== Botón inferior para regresar al login =====
                        Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: _regresarLogin,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: primary, width: 1.5),
                                foregroundColor: primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Volver al inicio de sesión'),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
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

  // ===== Widget del formulario de recuperación =====
  Widget _buildFormularioRecuperacion(ThemeData theme, Color primary) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ===== Explicación del proceso =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.security,
                  color: Colors.blue.shade600,
                  size: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona cómo quieres recibir tu código de verificación de 6 dígitos.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ===== Selección de método (Email o SMS) =====
          Text(
            'Método de verificación',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              // Opción Email
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _metodoSeleccionado = 'email'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _metodoSeleccionado == 'email' ? primary.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _metodoSeleccionado == 'email' ? primary : Colors.grey.shade300,
                        width: _metodoSeleccionado == 'email' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          color: _metodoSeleccionado == 'email' ? primary : Colors.grey.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Email',
                          style: TextStyle(
                            color: _metodoSeleccionado == 'email' ? primary : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Opción SMS
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _metodoSeleccionado = 'sms'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _metodoSeleccionado == 'sms' ? primary.withOpacity(0.1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _metodoSeleccionado == 'sms' ? primary : Colors.grey.shade300,
                        width: _metodoSeleccionado == 'sms' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.sms_outlined,
                          color: _metodoSeleccionado == 'sms' ? primary : Colors.grey.shade600,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SMS',
                          style: TextStyle(
                            color: _metodoSeleccionado == 'sms' ? primary : Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 25),

          // ===== Campo según método seleccionado =====
          if (_metodoSeleccionado == 'email') ...[
            // Campo de email
            TextFormField(
              controller: _emailController,
              focusNode: _emailFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _enviarCodigoVerificacion(),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
              ),
              // ===== Validación del campo email =====
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu correo electrónico';
                }
                // Validación de formato de email usando RegExp
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
                  return 'Ingresa un correo válido';
                }
                return null;
              },
            ),
          ] else ...[
            // Campo de teléfono
            TextFormField(
              controller: _telefonoController,
              focusNode: _telefonoFocus,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _enviarCodigoVerificacion(),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              decoration: InputDecoration(
                labelText: 'Número de celular',
                hintText: '3001234567',
                prefixIcon: const Icon(Icons.phone_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: primary, width: 2),
                ),
              ),
              // ===== Validación del campo teléfono =====
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ingresa tu número de celular';
                }
                if (value.length < 10) {
                  return 'El número debe tener 10 dígitos';
                }
                return null;
              },
            ),
          ],

          const SizedBox(height: 30),

          // ===== Botón para enviar código =====
          SizedBox(
            height: 50,
            child: FilledButton(
              onPressed: _enviando ? null : _enviarCodigoVerificacion,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Deshabilitar cuando está enviando
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: _enviando
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
                        SizedBox(width: 10),
                        Text('Enviando...'),
                      ],
                    )
                  : Text('Enviar código por ${_metodoSeleccionado == 'email' ? 'correo' : 'SMS'}'),
            ),
          ),
        ],
      ),
    );
  }

  // ===== Widget de pantalla de verificación de código =====
  Widget _buildPantallaVerificacion(ThemeData theme, Color primary) {
    return Form(
      key: _codigoFormKey,
      child: Column(
        children: [
          // ===== Icono de verificación =====
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_clock_outlined,
              size: 40,
              color: Colors.blue.shade600,
            ),
          ),

          const SizedBox(height: 24),

          // ===== Título de verificación =====
          Text(
            'Verificar código',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: primary,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // ===== Información del envío =====
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              children: [
                Text(
                  'Código enviado por ${_metodoSeleccionado == 'email' ? 'correo a:' : 'SMS a:'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _metodoSeleccionado == 'email' ? _emailController.text : _telefonoController.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // ===== Campos para el código de 6 dígitos =====
          Text(
            'Ingresa el código de 6 dígitos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Fila de campos para el código
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 45,
                height: 55,
                child: TextFormField(
                  controller: _codigoControllers[index],
                  focusNode: _codigoFocusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    counterText: '',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: primary, width: 2),
                    ),
                  ),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
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
              );
            }),
          ),

          const SizedBox(height: 30),

          // ===== Botón de verificar =====
          SizedBox(
            height: 50,
            width: double.infinity,
            child: FilledButton(
              onPressed: _verificando ? null : _verificarCodigo,
              style: FilledButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: Colors.grey.shade400,
              ),
              child: _verificando
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
                        SizedBox(width: 10),
                        Text('Verificando...'),
                      ],
                    )
                  : const Text('Verificar código'),
            ),
          ),

          const SizedBox(height: 20),

          // ===== Botón de reenviar código =====
          TextButton.icon(
            onPressed: () {
              setState(() {
                _codigoEnviado = false;
                // Limpiar campos del código
                for (var controller in _codigoControllers) {
                  controller.clear();
                }
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reenviar código'),
            style: TextButton.styleFrom(
              foregroundColor: primary,
            ),
          ),
        ],
      ),
    );
  }
}
