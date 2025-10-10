import 'package:flutter/material.dart';

class EntrenamientoProximo {
  final DateTime fecha;
  final String tipo;
  final String duracion;
  final String objetivos;
  final String ubicacion;
  final String? notas;

  EntrenamientoProximo({
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
    'Técnico', 'Físico', 'Táctico', 'Mixto', 'Recuperación', 'Pre-partido'
  ];

  @override
  void initState() {
    super.initState();
    _cargarEntrenamientosEjemplo();
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

  // Cargar algunos entrenamientos de ejemplo al iniciar
  void _cargarEntrenamientosEjemplo() {
    setState(() {
      _entrenamientosProximos.addAll([
        EntrenamientoProximo(
          fecha: DateTime.now().add(const Duration(days: 2)),
          tipo: 'Técnico',
          duracion: '90 min',
          objetivos: 'Centros y remates',
          ubicacion: 'Campo principal',
          notas: 'Llevar conos adicionales',
        ),
        EntrenamientoProximo(
          fecha: DateTime.now().add(const Duration(days: 5)),
          tipo: 'Físico',
          duracion: '75 min',
          objetivos: 'Fuerza y resistencia',
          ubicacion: 'Gimnasio',
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
              child: _entrenamientosProximos.isEmpty
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
                      color: Color(0xFF00f5ff),
                      size: 20,
                    ),
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
          color: Colors.grey[300]!,
          width: 1,
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
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
              style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(value),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
              // Título del modal
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
              
              // Formulario
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
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha del Entrenamiento',
                hintText: 'Selecciona la fecha',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _seleccionarFecha,
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
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas (Opcional)',
                hintText: 'Recordatorios o información adicional',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
  void _guardarEntrenamiento(bool esEdicion, int index) {
    if (_formKey.currentState!.validate()) {
      final entrenamiento = EntrenamientoProximo(
        fecha: _fechaSeleccionada!,
        tipo: _tipoSeleccionado!,
        duracion: _duracionController.text,
        objetivos: _objetivosController.text,
        ubicacion: _ubicacionController.text,
        notas: _notasController.text.isEmpty ? null : _notasController.text,
      );

      setState(() {
        if (esEdicion) {
          _entrenamientosProximos[index] = entrenamiento;
        } else {
          _entrenamientosProximos.add(entrenamiento);
        }
        // Ordenar por fecha para mantener cronología
        _entrenamientosProximos.sort((a, b) => a.fecha.compareTo(b.fecha));
      });

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(esEdicion 
            ? 'Entrenamiento actualizado correctamente' 
            : 'Entrenamiento planificado correctamente'),
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
        content: const Text('¿Estás seguro de que quieres eliminar este entrenamiento planificado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _entrenamientosProximos.removeAt(index);
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
    _fechaController.clear();
    _duracionController.clear();
    _objetivosController.clear();
    _ubicacionController.clear();
    _notasController.clear();
    _tipoSeleccionado = null;
    _fechaSeleccionada = null;
  }
}