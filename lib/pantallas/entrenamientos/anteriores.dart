import 'package:flutter/material.dart';
import 'proximos.dart';

class EntrenamientoAnterior {
  final DateTime fecha;
  final String tipo;
  final String duracion;
  final String intensidad;
  final String objetivos;
  final String ubicacion;
  final String observaciones;

  EntrenamientoAnterior({
    required this.fecha,
    required this.tipo,
    required this.duracion,
    required this.intensidad,
    required this.objetivos,
    required this.ubicacion,
    required this.observaciones,
  });
}

class EntrenamientosAnterioresPage extends StatefulWidget {
  const EntrenamientosAnterioresPage({super.key});

  @override
  State<EntrenamientosAnterioresPage> createState() => _EntrenamientosAnterioresPageState();
}

class _EntrenamientosAnterioresPageState extends State<EntrenamientosAnterioresPage> {
  final List<EntrenamientoAnterior> _entrenamientosAnteriores = [];
  
  final _formAnteriorKey = GlobalKey<FormState>();
  final _fechaAnteriorController = TextEditingController();
  final _duracionController = TextEditingController();
  final _objetivosController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _observacionesController = TextEditingController();
  
  String? _tipoSeleccionado;
  String? _intensidadSeleccionada;
  DateTime? _fechaEntrenamientoAnterior;

  final List<String> _tiposEntrenamiento = [
    'Técnico', 'Físico', 'Táctico', 'Mixto', 'Recuperación', 'Pre-partido'
  ];

  final List<String> _intensidades = [
    'Baja', 'Media', 'Alta', 'Muy Alta'
  ];

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientosEjemplo();
  }

  @override
  void dispose() {
    _fechaAnteriorController.dispose();
    _duracionController.dispose();
    _objetivosController.dispose();
    _ubicacionController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  // Carga algunos entrenamientos de ejemplo para mostrar al usuario
  void _cargarEntrenamientosEjemplo() {
    setState(() {
      _entrenamientosAnteriores.addAll([
        EntrenamientoAnterior(
          fecha: DateTime.now().subtract(const Duration(days: 3)),
          tipo: 'Técnico',
          duracion: '90 min',
          intensidad: 'Media',
          objetivos: 'Pases y control',
          ubicacion: 'Campo principal',
          observaciones: 'Buen rendimiento general',
        ),
        EntrenamientoAnterior(
          fecha: DateTime.now().subtract(const Duration(days: 7)),
          tipo: 'Físico',
          duracion: '75 min',
          intensidad: 'Alta',
          objetivos: 'Resistencia cardiovascular',
          ubicacion: 'Gimnasio',
          observaciones: 'Intensidad adecuada mantenida',
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Entrenamientos',
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddButton(
                'Registrar Entrenamiento Anterior',
                Icons.add_box,
                _mostrarFormularioEntrenamientoAnterior,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _entrenamientosAnteriores.isEmpty
                  ? _buildEmptyState('No hay entrenamientos registrados', Icons.fitness_center)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _entrenamientosAnteriores.length,
                      itemBuilder: (context, index) {
                        return _buildEntrenamientoAnteriorCard(_entrenamientosAnteriores[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Header que permite navegar entre entrenamientos anteriores y próximos
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Botón Anteriores (activo)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center, color: Color(0xFF00f5ff), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Anteriores',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00f5ff),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 48, color: Colors.grey[300]),
          // Botón Próximos (inactivo)
          Expanded(
            child: GestureDetector(
              onTap: _navegarAEntrenamientosProximos,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_available, color: Color(0xFF1a1a2e), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Próximos',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a2e),
                      ),
                      overflow: TextOverflow.ellipsis,
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

  void _navegarAEntrenamientosProximos() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EntrenamientosProximosPage()),
    );
  }

  Widget _buildAddButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1a1a2e),
            Color(0xFF16213e),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1a1a2e).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF00f5ff), size: 24),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Color(0xFF00f5ff),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrenamientoAnteriorCard(EntrenamientoAnterior entrenamiento, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  entrenamiento.tipo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _getColorTipo(entrenamiento.tipo),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entrenamiento.intensidad,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Fecha', _formatDate(entrenamiento.fecha)),
          _buildInfoRow('Duración', entrenamiento.duracion),
          _buildInfoRow('Ubicación', entrenamiento.ubicacion),
          _buildInfoRow('Objetivos', entrenamiento.objetivos),
          if (entrenamiento.observaciones.isNotEmpty)
            _buildInfoRow('Observaciones', entrenamiento.observaciones),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editarEntrenamiento(index),
                icon: const Icon(Icons.edit, color: Color(0xFF0065F8)),
              ),
              IconButton(
                onPressed: () => _eliminarEntrenamiento(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Devuelve el color asociado a cada tipo de entrenamiento
  Color _getColorTipo(String tipo) {
    switch (tipo) {
      case 'Técnico':
        return const Color(0xFF2196F3);
      case 'Físico':
        return const Color(0xFFFF5722);
      case 'Táctico':
        return const Color(0xFF9C27B0);
      case 'Mixto':
        return const Color(0xFF4CAF50);
      case 'Recuperación':
        return const Color(0xFF00BCD4);
      case 'Pre-partido':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF757575);
    }
  }

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  void _mostrarFormularioEntrenamientoAnterior() {
    _limpiarFormulario();
    _mostrarModal('Registrar Entrenamiento', false, -1);
  }

  void _editarEntrenamiento(int index) {
    final entrenamiento = _entrenamientosAnteriores[index];
    _cargarDatosEnFormulario(entrenamiento);
    _mostrarModal('Editar Entrenamiento', true, index);
  }

  // Carga los datos del entrenamiento en el formulario para edición
  void _cargarDatosEnFormulario(EntrenamientoAnterior entrenamiento) {
    _fechaEntrenamientoAnterior = entrenamiento.fecha;
    _fechaAnteriorController.text = _formatDate(entrenamiento.fecha);
    _tipoSeleccionado = entrenamiento.tipo;
    _duracionController.text = entrenamiento.duracion;
    _intensidadSeleccionada = entrenamiento.intensidad;
    _objetivosController.text = entrenamiento.objetivos;
    _ubicacionController.text = entrenamiento.ubicacion;
    _observacionesController.text = entrenamiento.observaciones;
  }

  // Muestra un modal con el formulario para crear o editar entrenamientos
  void _mostrarModal(String titulo, bool esEdicion, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: _buildFormularioEntrenamiento(esEdicion, index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormularioEntrenamiento(bool esEdicion, int index) {
    return Form(
      key: _formAnteriorKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _fechaAnteriorController,
              decoration: const InputDecoration(
                labelText: 'Fecha del Entrenamiento',
                hintText: 'Selecciona la fecha',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _seleccionarFechaAnterior,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor selecciona una fecha';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _tipoSeleccionado,
              decoration: const InputDecoration(
                labelText: 'Tipo de Entrenamiento',
                prefixIcon: Icon(Icons.fitness_center),
                border: OutlineInputBorder(),
              ),
              items: _tiposEntrenamiento.map((tipo) {
                return DropdownMenuItem(value: tipo, child: Text(tipo));
              }).toList(),
              onChanged: (value) => setState(() => _tipoSeleccionado = value),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona un tipo';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _duracionController,
              decoration: const InputDecoration(
                labelText: 'Duración',
                hintText: 'Ej: 90 min',
                prefixIcon: Icon(Icons.timer),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la duración';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _intensidadSeleccionada,
              decoration: const InputDecoration(
                labelText: 'Intensidad',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
              ),
              items: _intensidades.map((intensidad) {
                return DropdownMenuItem(value: intensidad, child: Text(intensidad));
              }).toList(),
              onChanged: (value) => setState(() => _intensidadSeleccionada = value),
              validator: (value) {
                if (value == null) {
                  return 'Por favor selecciona una intensidad';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ubicacionController,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ej: Campo principal, Gimnasio',
                prefixIcon: Icon(Icons.location_on),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa la ubicación';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _objetivosController,
              decoration: const InputDecoration(
                labelText: 'Objetivos',
                hintText: 'Ej: Mejorar pases, Resistencia',
                prefixIcon: Icon(Icons.flag),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa los objetivos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesController,
              decoration: const InputDecoration(
                labelText: 'Observaciones (Opcional)',
                hintText: 'Notas adicionales sobre el entrenamiento',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF1a1a2e),
                          Color(0xFF16213e),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1a1a2e).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: () => _guardarEntrenamiento(esEdicion, index),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save, color: const Color(0xFF00f5ff), size: 24),
                            const SizedBox(width: 10),
                            Text(
                              esEdicion ? 'Actualizar' : 'Guardar',
                              style: const TextStyle(
                                color: Color(0xFF00f5ff),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }

  void _seleccionarFechaAnterior() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEntrenamientoAnterior ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    
    if (fecha != null) {
      setState(() {
        _fechaEntrenamientoAnterior = fecha;
        _fechaAnteriorController.text = _formatDate(fecha);
      });
    }
  }

  // Guarda un nuevo entrenamiento o actualiza uno existente
  void _guardarEntrenamiento(bool esEdicion, int index) {
    if (_formAnteriorKey.currentState!.validate()) {
      final entrenamiento = EntrenamientoAnterior(
        fecha: _fechaEntrenamientoAnterior!,
        tipo: _tipoSeleccionado!,
        duracion: _duracionController.text,
        intensidad: _intensidadSeleccionada!,
        objetivos: _objetivosController.text,
        ubicacion: _ubicacionController.text,
        observaciones: _observacionesController.text,
      );

      setState(() {
        if (esEdicion) {
          _entrenamientosAnteriores[index] = entrenamiento;
        } else {
          _entrenamientosAnteriores.add(entrenamiento);
        }
        _entrenamientosAnteriores.sort((a, b) => b.fecha.compareTo(a.fecha));
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esEdicion 
            ? 'Entrenamiento actualizado correctamente' 
            : 'Entrenamiento registrado correctamente'),
          backgroundColor: const Color(0xFF0065F8),
        ),
      );
    }
  }

  void _eliminarEntrenamiento(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrenamiento'),
        content: const Text('¿Estás seguro de que quieres eliminar este entrenamiento?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _entrenamientosAnteriores.removeAt(index);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entrenamiento eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _fechaAnteriorController.clear();
    _duracionController.clear();
    _objetivosController.clear();
    _ubicacionController.clear();
    _observacionesController.clear();
    _tipoSeleccionado = null;
    _intensidadSeleccionada = null;
    _fechaEntrenamientoAnterior = null;
  }
}