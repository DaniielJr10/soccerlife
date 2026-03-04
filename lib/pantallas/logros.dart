import 'package:flutter/material.dart';

/// Página de logros del jugador donde puede ver sus medallas y reconocimientos
/// Incluye logros desbloqueados, progreso y objetivos por alcanzar
class LogrosPage extends StatefulWidget {
  const LogrosPage({super.key});

  @override
  State<LogrosPage> createState() => _LogrosPageState();
}

class _LogrosPageState extends State<LogrosPage>
    with TickerProviderStateMixin {
  
  // Controlador para animaciones
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Datos de logros (en producción vendrían de una API)
  final List<Map<String, dynamic>> _logros = [
    {
      'id': 1,
      'titulo': 'Primer Gol',
      'descripcion': 'Anota tu primer gol en un partido oficial',
      'icono': Icons.sports_soccer,
      'desbloqueado': true,
      'progreso': 100,
      'objetivo': 1,
      'color': Colors.green,
      'fecha_desbloqueo': '15 Mar 2024',
    },
    {
      'id': 2,
      'titulo': 'Goleador',
      'descripcion': 'Anota 10 goles en una temporada',
      'icono': Icons.emoji_events,
      'desbloqueado': true,
      'progreso': 100,
      'objetivo': 10,
      'color': Colors.amber,
      'fecha_desbloqueo': '20 Jun 2024',
    },
    {
      'id': 3,
      'titulo': 'Asistente',
      'descripcion': 'Realiza 5 asistencias en una temporada',
      'icono': Icons.sports_handball,
      'desbloqueado': true,
      'progreso': 100,
      'objetivo': 5,
      'color': Colors.blue,
      'fecha_desbloqueo': '10 May 2024',
    },
    {
      'id': 4,
      'titulo': 'Invencible',
      'descripcion': 'Juega 5 partidos consecutivos sin perder',
      'icono': Icons.shield,
      'desbloqueado': false,
      'progreso': 3,
      'objetivo': 5,
      'color': Colors.purple,
      'fecha_desbloqueo': null,
    },
    {
      'id': 5,
      'titulo': 'Máximo Goleador',
      'descripcion': 'Anota 20 goles en una temporada',
      'icono': Icons.military_tech,
      'desbloqueado': false,
      'progreso': 15,
      'objetivo': 20,
      'color': Colors.orange,
      'fecha_desbloqueo': null,
    },
    {
      'id': 6,
      'titulo': 'Jugador Ejemplar',
      'descripcion': 'Completa una temporada sin tarjetas rojas',
      'icono': Icons.star,
      'desbloqueado': true,
      'progreso': 100,
      'objetivo': 1,
      'color': Colors.deepPurple,
      'fecha_desbloqueo': '28 Ago 2024',
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildLogrosBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarDialogoRegistrarLogro(),
        backgroundColor: const Color(0xFF00f5ff),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Registrar Logro',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Construye la barra de aplicación personalizada
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Logros',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: _compartirLogros,
        ),
      ],
    );
  }

  /// Construye el cuerpo principal de la pantalla
  Widget _buildLogrosBody() {
    final logrosDesbloqueados = _logros.where((logro) => logro['desbloqueado']).length;
    final totalLogros = _logros.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgresoGeneral(logrosDesbloqueados, totalLogros),
          const SizedBox(height: 20),
          _buildCategoriasLogros(),
          const SizedBox(height: 20),
          _buildListaLogros(),
        ],
      ),
    );
  }

  /// Construye la tarjeta de progreso general
  Widget _buildProgresoGeneral(int desbloqueados, int total) {
    final porcentaje = (desbloqueados / total * 100).toInt();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00f5ff),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00f5ff).withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            'Progreso de Logros',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$desbloqueados de $total desbloqueados',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: desbloqueados / total,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$porcentaje% completado',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye las categorías de logros
  Widget _buildCategoriasLogros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCategoriaCard(
                'Goles',
                Icons.sports_soccer,
                Colors.green,
                2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoriaCard(
                'Asistencias',
                Icons.sports_handball,
                Colors.blue,
                1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoriaCard(
                'Disciplina',
                Icons.shield,
                Colors.purple,
                1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Construye una tarjeta de categoría
  Widget _buildCategoriaCard(String titulo, IconData icono, Color color, int cantidad) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$cantidad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de logros
  Widget _buildListaLogros() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Todos los Logros',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _logros.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final logro = _logros[index];
            return _buildLogroCard(logro);
          },
        ),
      ],
    );
  }

  /// Construye una tarjeta de logro individual
  Widget _buildLogroCard(Map<String, dynamic> logro) {
    final bool desbloqueado = logro['desbloqueado'];
    final int progreso = logro['progreso'];
    final int objetivo = logro['objetivo'];
    final double porcentajeProgreso = progreso / objetivo;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: desbloqueado
            ? Border.all(color: logro['color'].withValues(alpha: 0.3), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: desbloqueado
                ? logro['color'].withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono del logro
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: desbloqueado
                  ? logro['color']
                  : Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              logro['icono'],
              color: desbloqueado ? Colors.white : Colors.grey,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          
          // Información del logro
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        logro['titulo'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: desbloqueado ? Colors.black87 : Colors.grey,
                        ),
                      ),
                    ),
                    if (desbloqueado)
                      Icon(
                        Icons.check_circle,
                        color: logro['color'],
                        size: 20,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  logro['descripcion'],
                  style: TextStyle(
                    fontSize: 12,
                    color: desbloqueado ? Colors.black54 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Barra de progreso o fecha de desbloqueo
                if (desbloqueado)
                  Text(
                    'Desbloqueado: ${logro['fecha_desbloqueo']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: logro['color'],
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Progreso: $progreso/$objetivo',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${(porcentajeProgreso * 100).toInt()}%',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: porcentajeProgreso,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: logro['color'],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Función para compartir logros
  void _compartirLogros() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Compartiendo logros...'),
        backgroundColor: Color(0xFF00f5ff),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Muestra el diálogo para registrar un nuevo logro
  void _mostrarDialogoRegistrarLogro() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _DialogoRegistrarLogro(
          onLogroRegistrado: _agregarNuevoLogro,
        );
      },
    );
  }

  /// Agrega un nuevo logro a la lista
  void _agregarNuevoLogro(Map<String, dynamic> nuevoLogro) {
    setState(() {
      nuevoLogro['id'] = _logros.length + 1;
      nuevoLogro['desbloqueado'] = true;
      nuevoLogro['progreso'] = nuevoLogro['objetivo'];
      nuevoLogro['fecha_desbloqueo'] = _formatearFechaActual();
      _logros.insert(0, nuevoLogro); // Agregar al inicio de la lista
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('¡Logro "${nuevoLogro['titulo']}" registrado exitosamente!'),
        backgroundColor: const Color(0xFF00f5ff),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            // Scroll hasta arriba para ver el nuevo logro
          },
        ),
      ),
    );
  }

  /// Formatea la fecha actual
  String _formatearFechaActual() {
    final now = DateTime.now();
    final meses = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${now.day} ${meses[now.month - 1]} ${now.year}';
  }
}

/// Widget de diálogo para registrar un nuevo logro
class _DialogoRegistrarLogro extends StatefulWidget {
  final Function(Map<String, dynamic>) onLogroRegistrado;

  const _DialogoRegistrarLogro({
    required this.onLogroRegistrado,
  });

  @override
  State<_DialogoRegistrarLogro> createState() => _DialogoRegistrarLogroState();
}

class _DialogoRegistrarLogroState extends State<_DialogoRegistrarLogro> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _objetivoController = TextEditingController(text: '1');
  
  IconData _iconoSeleccionado = Icons.emoji_events;
  
  final List<IconData> _iconosDisponibles = [
    Icons.emoji_events,
    Icons.sports_soccer,
    Icons.sports_handball,
    Icons.shield,
    Icons.military_tech,
    Icons.star,
    Icons.sports_tennis,
    Icons.workspace_premium,
    Icons.celebration,
    Icons.grade,
  ];
  


  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _objetivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00f5ff).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF00f5ff),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Registrar Nuevo Logro',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Título
                TextFormField(
                  controller: _tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título del Logro',
                    hintText: 'Ej: Mi Primer Hat-trick',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.title),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un título';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Descripción
                TextFormField(
                  controller: _descripcionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Descripción',
                    hintText: 'Describe qué logro obtuviste',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.description),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una descripción';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Objetivo
                TextFormField(
                  controller: _objetivoController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Objetivo (número)',
                    hintText: '1',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.flag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un objetivo';
                    }
                    final numero = int.tryParse(value);
                    if (numero == null || numero <= 0) {
                      return 'Por favor ingresa un número válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Selector de icono
                const Text(
                  'Selecciona un icono:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 60,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _iconosDisponibles.length,
                    itemBuilder: (context, index) {
                      final icono = _iconosDisponibles[index];
                      final seleccionado = icono == _iconoSeleccionado;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _iconoSeleccionado = icono;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: seleccionado 
                                ? const Color(0xFF00f5ff).withValues(alpha: 0.2)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: seleccionado
                                ? Border.all(color: const Color(0xFF00f5ff), width: 2)
                                : null,
                          ),
                          child: Icon(
                            icono,
                            color: seleccionado 
                                ? const Color(0xFF00f5ff)
                                : Colors.grey[600],
                            size: 24,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _registrarLogro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00f5ff),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Registrar',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  void _registrarLogro() {
    if (_formKey.currentState!.validate()) {
      final nuevoLogro = {
        'titulo': _tituloController.text.trim(),
        'descripcion': _descripcionController.text.trim(),
        'icono': _iconoSeleccionado,
        'objetivo': int.parse(_objetivoController.text),
        'color': const Color(0xFF00f5ff),
      };
      
      widget.onLogroRegistrado(nuevoLogro);
      Navigator.of(context).pop();
    }
  }
}
