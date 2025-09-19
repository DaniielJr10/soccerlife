import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pantalla de Registro de Soccer Life
// Este archivo define una UI profesional que sigue la misma estructura
// que el login y recuperación, con 2 pasos: Información Personal e Información Deportiva.

/// Pantalla de registro profesional con 2 pasos y diseño consistente.
class RegistrarsePage extends StatefulWidget {
  const RegistrarsePage({super.key});

  @override
  State<RegistrarsePage> createState() => _RegistrarsePageState();
}

class _RegistrarsePageState extends State<RegistrarsePage> {
  // Estados del formulario
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentStep = 0;
  
  // Controladores de texto
  final _emailController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _fechaNacimientoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _clubController = TextEditingController();
  
  // Focos
  final _emailFocus = FocusNode();
  final _nombreFocus = FocusNode();
  final _apellidoFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();
  final _telefonoFocus = FocusNode();
  final _clubFocus = FocusNode();
  
  // Estados de UI
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _registroExitoso = false;
  DateTime? _fechaNacimiento;
  String? _posicionSeleccionada;
  
  // Lista de posiciones de fútbol
  final List<String> _posiciones = [
    'Arquero',
    'Defensa Central',
    'Lateral',
    'Volante',
    'Extremo',
    'Delantero',
  ];

  @override
  void dispose() {
    // Liberar recursos
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
    _pageController.dispose();
    super.dispose();
  }

  // Validaciones específicas
  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
      return 'Ingresa un correo electrónico válido';
    }
    // Simulación de verificación de correo existente
    if (value.toLowerCase() == 'admin@soccerlife.com') {
      return 'El correo electrónico ya está registrado';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
      return 'Debe contener mayúscula, minúscula y número';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de teléfono es obligatorio';
    }
    // Validación para números colombianos (ejemplo)
    if (!RegExp(r'^[+]?[0-9]{10,15}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'El número de teléfono es inválido';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  // Seleccionar fecha de nacimiento
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 años
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 4380)), // 12 años mínimo
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.green.shade800,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
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

  // Siguiente paso
  void _nextStep() {
    if (_currentStep == 0 && _validateStep1()) {
      setState(() => _currentStep = 1);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Paso anterior
  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep = 0);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  // Validar paso 1 (Información Personal)
  bool _validateStep1() {
    return _validateRequired(_nombreController.text, 'El nombre') == null &&
           _validateRequired(_apellidoController.text, 'El apellido') == null &&
           _fechaNacimiento != null &&
           _validateEmail(_emailController.text) == null &&
           _validatePhone(_telefonoController.text) == null &&
           _validatePassword(_passwordController.text) == null &&
           _validateConfirmPassword(_confirmPasswordController.text) == null;
  }

  // Validar paso 2 (Información Deportiva)
  bool _validateStep2() {
    return _posicionSeleccionada != null;
  }

  // Registrar usuario
  Future<void> _registrarUsuario() async {
    if (!_validateStep2()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() => _isLoading = true);
    
    // Simulación de registro con tiempo más realista
    await Future.delayed(const Duration(seconds: 3));
    
    setState(() {
      _isLoading = false;
      _registroExitoso = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = Colors.green.shade800;
    
    if (_registroExitoso) {
      return _buildSuccessScreen(theme, primary);
    }
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight > 32 ? constraints.maxHeight - 32 : 0
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header con botón de regreso
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios),
                              tooltip: 'Regresar',
                            ),
                            const Spacer(),
                          ],
                        ),

                        // Logo y título
                        Column(
                          children: [
                            const SizedBox(height: 30),
                            Align(
                              child: Image.asset(
                                'images/logo.png',
                                width: 80,
                                height: 80,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Soccer Life',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Crear nueva cuenta',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),

                        const SizedBox(height: 40),

                        // Indicador de progreso
                        _buildProgressIndicator(primary),

                        const SizedBox(height: 30),

                        // Contenido de los pasos
                        Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: IndexedStack(
                            index: _currentStep,
                            children: [
                              _buildInformacionPersonal(theme, primary),
                              _buildInformacionDeportiva(theme, primary),
                            ],
                          ),
                        ),

                        const Spacer(),

                        // Botones de navegación
                        _buildNavigationButtons(primary),

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

  Widget _buildProgressIndicator(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStepIndicator(0, 'Personal', primary),
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _currentStep >= 1 ? primary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              _buildStepIndicator(1, 'Deportiva', primary),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _currentStep == 0 ? 'Información Personal' : 'Información Deportiva',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _currentStep == 0 
                ? 'Completa tu información básica'
                : 'Completa tu perfil futbolístico',
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, Color primary) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;
    
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive ? primary : Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: isCompleted
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Center(
                  child: Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isActive ? primary : Colors.grey.shade600,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(Color primary) {
    return Column(
      children: [
        // Botón principal (Siguiente o Registrar)
        SizedBox(
          height: 50,
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : (_currentStep == 0 ? _nextStep : _registrarUsuario),
            style: FilledButton.styleFrom(
              backgroundColor: primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: Colors.grey.shade400,
            ),
            child: _isLoading
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
                      Text('Creando cuenta...'),
                    ],
                  )
                : Text(_currentStep == 0 ? 'Siguiente' : 'Crear mi cuenta'),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Botón secundario
        SizedBox(
          height: 50,
          width: double.infinity,
          child: _currentStep == 0
              ? OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary, width: 1.5),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('¿Ya tienes cuenta?'),
                )
              : OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primary, width: 1.5),
                    foregroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Anterior'),
                ),
        ),
      ],
    );
  }

  Widget _buildInformacionPersonal(ThemeData theme, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título de la sección
        Text(
          'Información Personal',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 25),

        // Nombre
        TextFormField(
          controller: _nombreController,
          focusNode: _nombreFocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _apellidoFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'Nombre',
            hintText: 'Tu nombre',
            prefixIcon: const Icon(Icons.person_outline),
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
          validator: (value) => _validateRequired(value, 'El nombre'),
        ),

        const SizedBox(height: 20),

        // Apellido
        TextFormField(
          controller: _apellidoController,
          focusNode: _apellidoFocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_emailFocus),
          decoration: InputDecoration(
            labelText: 'Apellido',
            hintText: 'Tu apellido',
            prefixIcon: const Icon(Icons.person_outline),
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
          validator: (value) => _validateRequired(value, 'El apellido'),
        ),

        const SizedBox(height: 20),

        // Fecha de nacimiento
        TextFormField(
          controller: _fechaNacimientoController,
          readOnly: true,
          onTap: _selectDate,
          decoration: InputDecoration(
            labelText: 'Fecha de nacimiento',
            hintText: 'DD/MM/YYYY',
            prefixIcon: const Icon(Icons.calendar_today_outlined),
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
          validator: (value) {
            if (_fechaNacimiento == null) {
              return 'Selecciona tu fecha de nacimiento';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Correo electrónico
        TextFormField(
          controller: _emailController,
          focusNode: _emailFocus,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _telefonoFocus.requestFocus(),
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
          validator: _validateEmail,
        ),

        const SizedBox(height: 20),

        // Teléfono
        TextFormField(
          controller: _telefonoController,
          focusNode: _telefonoFocus,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
          decoration: InputDecoration(
            labelText: 'Teléfono',
            hintText: '+57 300 123 4567',
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
          validator: _validatePhone,
        ),

        const SizedBox(height: 20),

        // Contraseña
        TextFormField(
          controller: _passwordController,
          focusNode: _passwordFocus,
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.next,
          onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            hintText: 'Mínimo 8 caracteres',
            prefixIcon: const Icon(Icons.lock_outline),
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          validator: _validatePassword,
        ),

        const SizedBox(height: 20),

        // Confirmar contraseña
        TextFormField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocus,
          obscureText: _obscureConfirmPassword,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Confirmar contraseña',
            hintText: 'Repite tu contraseña',
            prefixIcon: const Icon(Icons.lock_outline),
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
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
          validator: _validateConfirmPassword,
        ),

        const SizedBox(height: 30),

        // Nota informativa
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Todos los campos son obligatorios',
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformacionDeportiva(ThemeData theme, Color primary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Título de la sección
        Text(
          'Información Deportiva',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 25),

        // Posición
        DropdownButtonFormField<String>(
          value: _posicionSeleccionada,
          decoration: InputDecoration(
            labelText: 'Posición',
            hintText: 'Selecciona tu posición',
            prefixIcon: const Icon(Icons.sports_soccer_outlined),
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
          items: _posiciones.map((posicion) {
            return DropdownMenuItem(
              value: posicion,
              child: Text(posicion),
            );
          }).toList(),
          onChanged: (value) => setState(() => _posicionSeleccionada = value),
          validator: (value) {
            if (value == null) {
              return 'Selecciona tu posición';
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        // Club
        TextFormField(
          controller: _clubController,
          focusNode: _clubFocus,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'Club actual (opcional)',
            hintText: 'Nombre de tu club',
            prefixIcon: const Icon(Icons.emoji_events_outlined),
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
        ),

        const SizedBox(height: 30),

        // Nota informativa
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sports_soccer_outlined,
                color: primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'La posición es obligatoria, el club es opcional',
                  style: TextStyle(
                    color: primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }






  Widget _buildSuccessScreen(ThemeData theme, Color primary) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF9),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animación de éxito
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withOpacity(0.2),
                      primary.withOpacity(0.1),
                      Colors.green.shade100.withOpacity(0.5),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: primary,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Título de éxito
              Text(
                '¡Bienvenido a Soccer Life!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primary,
                  fontSize: 26,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Mensaje personalizado
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Tu cuenta ha sido creada exitosamente, '),
                    TextSpan(
                      text: _nombreController.text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    const TextSpan(text: '. ¡Es hora de brillar en el campo!'),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer_outlined,
                      color: primary,
                      size: 32,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu perfil futbolístico',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Posición: ${_posicionSeleccionada ?? "No especificada"}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    if (_clubController.text.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Club: ${_clubController.text}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botón de confirmación elegante
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.rocket_launch_outlined, size: 20),
                  label: const Text(
                    'Empezar mi aventura',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Mensaje de verificación
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Revisa tu correo para verificar tu cuenta',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
