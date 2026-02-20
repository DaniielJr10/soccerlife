import 'package:flutter/material.dart';
import '../../services/entrenamientos_service.dart';

class EntrenamientoProximo {
  final String? id;
  final DateTime fecha;
  final String tipo;
  final String duracion;
  final String objetivos;
  final String ubicacion;
  final String? notas;

  EntrenamientoProximo({
    this.id,
    required this.fecha,
    required this.tipo,
    required this.duracion,
    required this.objetivos,
    required this.ubicacion,
    this.notas,
  });
}

// Pantalla para planificar y gestionar entrenamientos futuros
class EntrenamientosProximosPage extends StatefulWidget {
  const EntrenamientosProximosPage({super.key});

  @override
  State<EntrenamientosProximosPage> createState() => _EntrenamientosProximosPageState();
}

class _EntrenamientosProximosPageState extends State<EntrenamientosProximosPage> {
  final List<EntrenamientoProximo> _entrenamientosProximos = [];
  bool _cargando = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controladores del formulario
  final _fechaController = TextEditingController();
  final _duracionController = TextEditingController();
  final _objetivosController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _notasController = TextEditingController();
  
  String? _tipoSeleccionado;
  DateTime? _fechaSeleccionada;

  final List<String> _tiposEntrenamiento = [
    'Técnico', 'Físico', 'Táctico', 'Estratégico', 'Recuperación', 'Completo'
  ];

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientos();
  }

  Future<void> _cargarEntrenamientos() async {
    setState(() => _cargando = true);
    try {
      final resultado = await EntrenamientosService.obtenerEntrenamientosProximos();
      if (resultado['success'] == true && mounted) {
        final lista = resultado['entrenamientos'] as List;
        setState(() {
          _entrenamientosProximos
            ..clear()
            ..addAll(lista.map((e) => EntrenamientoProximo(
              id: e['_id'] as String?,
              fecha: DateTime.parse(e['fecha'] as String),
              tipo: (e['tipo'] as String?) ?? 'Técnico',
              duracion: '${e['duracion'] ?? 60} min',
              objetivos: (e['objetivos'] as String?) ?? '',
              ubicacion: (e['ubicacion'] as String?) ?? '',
              notas: e['notas'] as String?,
            )))
            ..sort((a, b) => a.fecha.compareTo(b.fecha));
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
    _fechaController.dispose();
    _duracionController.dispose();
    _objetivosController.dispose();
    _ubicacionController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
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
                'Programar Entrenamiento',
                Icons.event_available,
                () => _mostrarFormulario(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _entrenamientosProximos.isEmpty
                      ? _buildEmptyState('No hay entrenamientos programados', Icons.fitness_center)
                      : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _entrenamientosProximos.length,
                      itemBuilder: (context, index) {
                        return _buildEntrenamientoCard(_entrenamientosProximos[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Construye el header con navegación entre secciones
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
          // Botón Anteriores (inactivo)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: Color(0xFF1a1a2e),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Anteriores',
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
          Container(
            width: 1,
            height: 48,
            color: Colors.grey[300],
          ),
          // Botón Próximos (activo)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
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
                  Icon(
                    Icons.event_available,
                    color: Color(0xFF00f5ff),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Próximos',
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
        ],
      ),
    );
  }

  // Construye el botón principal de acción
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

  // Muestra un mensaje cuando no hay entrenamientos
  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntrenamientoCard(EntrenamientoProximo entrenamiento, int index) {
    final diasHasta = entrenamiento.fecha.difference(DateTime.now()).inDays;
    final esUrgente = diasHasta <= 1;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFF00f5ff),
          width: 1.5,
        ),
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
              if (esUrgente)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '¡Próximamente!',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Fecha', _formatDate(entrenamiento.fecha)),
          _buildInfoRow('Duración', entrenamiento.duracion),
          _buildInfoRow('Ubicación', entrenamiento.ubicacion),
          _buildInfoRow('Objetivos', entrenamiento.objetivos),
          if (entrenamiento.notas != null && entrenamiento.notas!.isNotEmpty)
            _buildInfoRow('Notas', entrenamiento.notas!),
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

  void _mostrarFormulario() {
    _limpiarFormulario();
    _mostrarModal('Programar Entrenamiento', false, -1);
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

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  void _editarEntrenamiento(int index) {
    final entrenamiento = _entrenamientosProximos[index];
    _cargarDatosEnFormulario(entrenamiento);
    _mostrarModal('Editar Entrenamiento', true, index);
  }

  void _cargarDatosEnFormulario(EntrenamientoProximo entrenamiento) {
    _fechaSeleccionada = entrenamiento.fecha;
    _fechaController.text = _formatDate(entrenamiento.fecha);
    _tipoSeleccionado = entrenamiento.tipo;
    _duracionController.text = entrenamiento.duracion;
    _objetivosController.text = entrenamiento.objetivos;
    _ubicacionController.text = entrenamiento.ubicacion;
    _notasController.text = entrenamiento.notas ?? '';
  }

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
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCompactField(
                        'Fecha',
                        _fechaController,
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _seleccionarFecha(),
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
                        'Notas',
                        _notasController,
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

  // Abre el selector de fecha
  void _seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (fecha != null) {
      setState(() {
        _fechaSeleccionada = fecha;
        _fechaController.text = _formatDate(fecha);
      });
    }
  }

  // Guarda o actualiza el entrenamiento
  Future<void> _guardarEntrenamiento(bool esEdicion, int index) async {
    if (_formKey.currentState!.validate()) {
      final durMinutos = _parseDuracion(_duracionController.text);

      if (esEdicion) {
        final id = _entrenamientosProximos[index].id;
        if (id != null) {
          final res = await EntrenamientosService.actualizarEntrenamiento(
            entrenamientoId: id,
            fecha: _fechaSeleccionada,
            duracion: durMinutos,
            tipo: _tipoSeleccionado,
            ubicacion: _ubicacionController.text,
            objetivos: _objetivosController.text,
            notas: _notasController.text.isEmpty ? null : _notasController.text,
          );
          if (!mounted) return;
          if (res['success'] != true) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${res['message']}'),
              backgroundColor: Colors.red,
            ));
            return;
          }
        }
        final entrenamiento = EntrenamientoProximo(
          id: _entrenamientosProximos[index].id,
          fecha: _fechaSeleccionada!,
          tipo: _tipoSeleccionado!,
          duracion: _duracionController.text,
          objetivos: _objetivosController.text,
          ubicacion: _ubicacionController.text,
          notas: _notasController.text.isEmpty ? null : _notasController.text,
        );
        setState(() {
          _entrenamientosProximos[index] = entrenamiento;
          _entrenamientosProximos.sort((a, b) => a.fecha.compareTo(b.fecha));
        });
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Entrenamiento actualizado correctamente'),
          backgroundColor: Color(0xFF0065F8),
        ));
        return;
      }

      // Nuevo entrenamiento: guardar en API
      final crearRes = await EntrenamientosService.crearEntrenamiento(
        fecha: _fechaSeleccionada!,
        duracion: durMinutos,
        tipo: _tipoSeleccionado!,
        ubicacion: _ubicacionController.text,
        objetivos: _objetivosController.text,
        notas: _notasController.text.isEmpty ? null : _notasController.text,
      );

      if (!mounted) return;

      if (crearRes['success'] == true) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Entrenamiento planificado correctamente'),
          backgroundColor: Color(0xFF0065F8),
        ));
        _cargarEntrenamientos();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${crearRes['message']}'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  void _eliminarEntrenamiento(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Entrenamiento'),
        content: const Text('¿Estás seguro de que quieres eliminar este entrenamiento planificado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final id = _entrenamientosProximos[index].id;
              if (id != null) {
                await EntrenamientosService.eliminarEntrenamiento(id);
              }
              if (mounted) {
                setState(() => _entrenamientosProximos.removeAt(index));
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
    _fechaController.clear();
    _duracionController.clear();
    _objetivosController.clear();
    _ubicacionController.clear();
    _notasController.clear();
    _tipoSeleccionado = null;
    _fechaSeleccionada = null;
  }
}