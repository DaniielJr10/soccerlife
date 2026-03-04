import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/user_recuperar.dart';
import 'nueva_password.dart';

class RecuperarPasswordPage extends StatefulWidget {
  const RecuperarPasswordPage({super.key});

  @override
  State<RecuperarPasswordPage> createState() => _RecuperarPasswordPageState();
}

class _RecuperarPasswordPageState extends State<RecuperarPasswordPage>
    with TickerProviderStateMixin {
  
  // Controladores de animaciones
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  
  // Controladores de formularios
  final _formKey = GlobalKey<FormState>();
  final _codigoFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final List<TextEditingController> _codigoControllers = List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _codigoFocusNodes = List.generate(4, (index) => FocusNode());
  final _emailFocus = FocusNode();
  
  // Estados de la interfaz
  bool _codigoEnviado = false;
  bool _enviando = false;
  bool _verificando = false;
  bool _emailFocused = false;
  bool _recuperacionExitosa = false;
  String? _tokenRecuperacion;
  String? _emailEnviado;

  @override
  void initState() {
    super.initState();
    _inicializarAnimaciones();
    _configurarListenersFocus();
    _iniciarAnimacionesEntrada();
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
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _configurarListenersFocus() {
    _emailFocus.addListener(() {
      setState(() => _emailFocused = _emailFocus.hasFocus);
    });
    for (var node in _codigoFocusNodes) {
      node.addListener(() => setState(() {}));
    }
  }

  void _iniciarAnimacionesEntrada() {
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
    _emailFocus.dispose();
    for (var controller in _codigoControllers) {
      controller.dispose();
    }
    for (var focusNode in _codigoFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  // Lógica principal de recuperación de contraseña
  
  // Envía el código de verificación al email
  Future<void> _enviarCodigoVerificacion() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _enviando = true);
      
      // Proporciona retroalimentación táctil al usuario
      HapticFeedback.lightImpact();
      
      final email = _emailController.text.trim();
      final resp = await UserRecuperarService.solicitarRecuperacionPorEmail(email: email);

      if (!mounted) return;

      setState(() {
        _enviando = false;
        if (resp['success'] == true) {
          _codigoEnviado = true;
          _emailEnviado = email;
        }
      });

      if (resp['success'] == true) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Código enviado. Revisa tu bandeja de correo.'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(resp['message'] ?? 'Error al enviar código'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  // Verifica si el código ingresado es correcto
  Future<void> _verificarCodigo() async {
    final codigoIngresado = _codigoControllers.map((c) => c.text).join();
    if (codigoIngresado.length != 4) return; // esperar a 4 dígitos
    setState(() => _verificando = true);
    HapticFeedback.lightImpact();

    final resp = await UserRecuperarService.verificarCodigoRecuperacion(
      email: _emailEnviado!,
      codigo: codigoIngresado,
    );

    if (!mounted) return;
    setState(() => _verificando = false);

    if (resp['success'] == true) {
      HapticFeedback.mediumImpact();
      setState(() {
        _tokenRecuperacion = resp['token'];
        _recuperacionExitosa = true; // pasar a siguiente pantalla (nueva contraseña)
      });
      _scaleController.reset();
      _scaleController.forward();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Código incorrecto')),
      );
      for (var controller in _codigoControllers) {
        controller.clear();
      }
      _codigoFocusNodes.first.requestFocus();
    }
  }

  // Regresa a la pantalla de inicio de sesión
  void _regresarLogin() {
    HapticFeedback.lightImpact();
    Navigator.of(context).pop();
  }

  // Validadores para los campos del formulario
  
  // Valida que el correo electrónico tenga un formato correcto
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  // Construcción de la interfaz de usuario
  
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
                // Fondo con la imagen de fútbol
                _buildFootballBackground(),
                // Contenido principal de la pantalla
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 20),
                        // Header con logo y título
                        SlideTransition(
                          position: _slideAnimation,
                          child: _buildHeader(),
                        ),
                        const SizedBox(height: 20),
                        // Formulario principal
                        SlideTransition(
                          position: _slideAnimation,
                          child: _codigoEnviado 
                            ? _buildVerificationScreen()
                            : _buildRecoveryForm(),
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
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

  // Métodos para construir los elementos de la interfaz
  
  // Crea el fondo con la imagen de fútbol
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

  // Header con el logo y título de la aplicación
  Widget _buildHeader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        // Logo de la aplicación (más grande)
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
            child: Image.asset(
              'images/logo.png',
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Título principal de la aplicación (más grande)
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

        // Subtítulo indicando la función de la pantalla (más grande)
        Center(
          child: Text(
            'Recuperar Contraseña',
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

  // Widgets auxiliares para la construcción de la interfaz
  




  // Campo de texto estilizado para el formulario
  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required IconData icon,
    required bool isFocused,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
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
            color: isFocused ? const Color(0xFF00f5ff) : Colors.white.withValues(alpha: 0.6),
            size: 22,
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
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
        errorStyle: const TextStyle(
          color: Color(0xFFff6b6b),
          fontWeight: FontWeight.w500,
        ),
      ),
      validator: validator,
    );
  }

  // Botón estilizado para las acciones principales
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
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
            ),
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
      ),
    );
  }

  // Formulario principal para la recuperación
  Widget _buildRecoveryForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explicación del proceso
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
                    Icons.security,
                    color: Color(0xFF00b4db),
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingresa tu correo electrónico registrado y te enviaremos un código de verificación',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Campo de correo electrónico
            _buildTextField(
              controller: _emailController,
              focusNode: _emailFocus,
              label: 'Correo Electrónico',
              hint: 'tu@email.com',
              icon: Icons.email_outlined,
              isFocused: _emailFocused,
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
            ),

            const SizedBox(height: 32),

            // Botón de enviar código
            _buildButton(
              onTap: _enviando ? null : _enviarCodigoVerificacion,
              text: 'Enviar código',
              isLoading: _enviando,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Pantalla de verificación del código
  Widget _buildVerificationScreen() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        key: _codigoFormKey,
        child: Column(
          children: [
            // Icono de verificación
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00b4db).withValues(alpha: 0.2),
                    const Color(0xFF0083b0).withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.lock_clock_outlined,
                size: 36,
                color: Color(0xFF00b4db),
              ),
            ),

            const SizedBox(height: 20),

            // Título de la sección de verificación
            Text(
              'Verificar Código',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF00f5ff),
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

            const SizedBox(height: 16),

            // Información sobre el envío del código
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
                  Text(
                    'Código enviado por correo a:',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _emailController.text,
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

            const SizedBox(height: 20),

            // Título para los campos del código
            const Text(
              'Ingresa el código de 4 dígitos',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),

            // Campos para ingresar el código de 4 dígitos
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                final isFocused = _codigoFocusNodes[index].hasFocus;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 60,
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isFocused
                          ? const Color(0xFF00f5ff)
                          : Colors.white.withValues(alpha: 0.25),
                      width: isFocused ? 2.0 : 1.2,
                    ),
                    color: isFocused
                        ? const Color(0xFF00f5ff).withValues(alpha: 0.10)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                  child: TextFormField(
                    controller: _codigoControllers[index],
                    focusNode: _codigoFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (val) {
                      // Pasa automáticamente al siguiente campo
                      if (val.isNotEmpty && index < 3) {
                        _codigoFocusNodes[index + 1].requestFocus();
                      }
                      // Verifica automáticamente cuando se completen 4 campos
                      if (index == 3 && val.isNotEmpty) {
                        _verificarCodigo();
                      }
                    },
                    onTap: () {
                      // Selecciona todo el texto del campo al tocarlo
                      _codigoControllers[index].selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: _codigoControllers[index].text.length,
                      );
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Botón de verificar
            _buildButton(
              onTap: _verificando ? null : _verificarCodigo,
              text: 'Verificar código',
              isLoading: _verificando,
            ),

            const SizedBox(height: 16),

            // Botón para reenviar el código
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.white.withValues(alpha: 0.05),
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
                      // Limpia todos los campos del código
                      for (var controller in _codigoControllers) { controller.clear(); }
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
                          color: Colors.white.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reenviar código',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
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

  // Pantalla que se muestra cuando la verificación es exitosa
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
                    
                    // Mensaje explicativo
                    Text(
                      'Tu identidad ha sido verificada exitosamente. Ahora puedes crear una nueva contraseña.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.8),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Botón de continuar
                    _buildButton(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (_tokenRecuperacion == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token no disponible')),
                          );
                          return;
                        }
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => NuevaPasswordPage(
                              token: _tokenRecuperacion!,
                            ),
                          ),
                        );
                      },
                      text: 'Crear Nueva Contraseña',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Opción para volver al inicio de sesión
                    TextButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: Text(
                        'Volver al inicio de sesión',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
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
