import 'package:flutter/material.dart';
import 'proximos.dart';
import '../../services/entrenamientos_service.dart';

class EntrenamientoAnterior {
  final String? id;
  final DateTime fecha;
  final String tipo;
  final String duracion;
  final String intensidad;
  final String objetivos;
  final String ubicacion;
  final String observaciones;

  EntrenamientoAnterior({
    this.id,
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
  bool _cargando = false;
  
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
    'Técnico', 'Físico', 'Táctico', 'Estratégico', 'Recuperación', 'Completo'
  ];

  final List<String> _intensidades = [
    'Baja', 'Media', 'Alta', 'Muy Alta'
  ];

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientos();
  }

  Future<void> _cargarEntrenamientos() async {
    setState(() => _cargando = true);
    try {
      final resultado = await EntrenamientosService.obtenerEntrenamientosAnteriores();
      if (resultado['success'] == true && mounted) {
        final lista = resultado['entrenamientos'] as List;
        setState(() {
          _entrenamientosAnteriores
            ..clear()
            ..addAll(lista.map((e) => EntrenamientoAnterior(
              id: e['_id'] as String?,
              fecha: DateTime.parse(e['fecha'] as String),
              tipo: (e['tipo'] as String?) ?? 'Técnico',
              duracion: '${e['duracion'] ?? 60} min',
              intensidad: (e['intensidad'] as String?) ?? 'Media',
              objetivos: (e['objetivos'] as String?) ?? '',
              ubicacion: (e['ubicacion'] as String?) ?? '',
              observaciones: (e['notas'] as String?) ?? '',
            )))
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
        });
      }
    } catch (e) {
      // silencioso en error de red
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  /// Extrae la duración en minutos de un texto como "90 min" o "90"
  int _parseDuracion(String texto) {
    final digits = texto.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 60;
    final val = int.parse(digits);
    if (val < 15) return 15;
    if (val > 300) return 300;
    return val;
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
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _entrenamientosAnteriores.isEmpty
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
        border: Border.all(color: const Color(0xFF00f5ff), width: 1.5),
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
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1a1a2e)),
            ),
          ),
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
    showDialog(
      context: context,
      builder: (context) => _buildFormularioEntrenamiento(titulo, esEdicion, index),
    );
  }

  Widget _buildFormularioEntrenamiento(String titulo, bool esEdicion, int index) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        color: Color(0xFF00f5ff),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Color(0xFF00f5ff), size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ),
            // Formulario scrollable
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formAnteriorKey,
                  child: Column(
                    children: [
                      _buildCompactField(
                        'Fecha',
                        _fechaAnteriorController,
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _seleccionarFechaAnterior(),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactDropdown(
                        'Tipo',
                        _tipoSeleccionado,
                        _tiposEntrenamiento,
                        (value) => setState(() => _tipoSeleccionado = value),
                        Icons.fitness_center,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Duración',
                        _duracionController,
                        Icons.timer,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactDropdown(
                        'Intensidad',
                        _intensidadSeleccionada,
                        _intensidades,
                        (value) => setState(() => _intensidadSeleccionada = value),
                        Icons.speed,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Ubicación',
                        _ubicacionController,
                        Icons.location_on,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Objetivos',
                        _objetivosController,
                        Icons.flag,
                        maxLines: 2,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Observaciones',
                        _observacionesController,
                        Icons.note,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => _guardarEntrenamiento(esEdicion, index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1a1a2e),
                            foregroundColor: const Color(0xFF00f5ff),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text(
                            esEdicion ? 'Actualizar' : 'Guardar',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF00f5ff),
                              fontWeight: FontWeight.bold,
                            ),
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
      ),
    );
  }

  Widget _buildCompactField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF1a1a2e),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFF0065F8)),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF1a1a2e)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff), width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 10),
        isDense: true,
      ),
    );
  }

  Widget _buildCompactDropdown(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Requerido' : null,
      style: const TextStyle(
        fontSize: 12,
        color: Color(0xFF1a1a2e),
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFF0065F8)),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF1a1a2e)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF00f5ff), width: 2),
        ),
        errorStyle: const TextStyle(fontSize: 10),
        isDense: true,
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(
            item,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1a1a2e),
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  // =============== Validaciones ===============
  
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
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
  Future<void> _guardarEntrenamiento(bool esEdicion, int index) async {
    if (_formAnteriorKey.currentState!.validate()) {
      // Si es edición, solo actualizar localmente
      if (esEdicion) {
        final entrenamiento = EntrenamientoAnterior(
          id: _entrenamientosAnteriores[index].id,
          fecha: _fechaEntrenamientoAnterior!,
          tipo: _tipoSeleccionado!,
          duracion: _duracionController.text,
          intensidad: _intensidadSeleccionada!,
          objetivos: _objetivosController.text,
          ubicacion: _ubicacionController.text,
          observaciones: _observacionesController.text,
        );
        setState(() {
          _entrenamientosAnteriores[index] = entrenamiento;
          _entrenamientosAnteriores.sort((a, b) => b.fecha.compareTo(a.fecha));
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Entrenamiento actualizado correctamente'),
          backgroundColor: Color(0xFF0065F8),
        ));
        return;
      }

      // Nuevo entrenamiento: guardar en API
      final durMinutos = _parseDuracion(_duracionController.text);
      final crearRes = await EntrenamientosService.crearEntrenamiento(
        fecha: _fechaEntrenamientoAnterior!,
        duracion: durMinutos,
        tipo: _tipoSeleccionado!,
        ubicacion: _ubicacionController.text,
        objetivos: _objetivosController.text,
        notas: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      );

      if (!mounted) return;

      if (crearRes['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${crearRes['message']}'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      final entrenamientoId = crearRes['entrenamiento']['_id'] as String;

      // Marcar como completado
      await EntrenamientosService.completarEntrenamiento(
        entrenamientoId: entrenamientoId,
        intensidad: _intensidadSeleccionada!,
        notas: _observacionesController.text.isEmpty ? null : _observacionesController.text,
      );

      if (!mounted) return;

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Entrenamiento registrado correctamente'),
        backgroundColor: Color(0xFF0065F8),
      ));
      _cargarEntrenamientos();
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
            onPressed: () async {
              Navigator.pop(context);
              final id = _entrenamientosAnteriores[index].id;
              if (id != null) {
                await EntrenamientosService.eliminarEntrenamiento(id);
              }
              if (mounted) {
                setState(() => _entrenamientosAnteriores.removeAt(index));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Entrenamiento eliminado'),
                  backgroundColor: Colors.red,
                ));
              }
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