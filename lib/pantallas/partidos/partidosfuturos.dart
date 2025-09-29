import 'package:flutter/material.dart';

/// Pantalla de partidos futuros de Soccer Life
/// Permite programar y gestionar partidos próximos
class PartidosFuturosPage extends StatefulWidget {
  const PartidosFuturosPage({super.key});

  @override
  State<PartidosFuturosPage> createState() => _PartidosFuturosPageState();
}

class _PartidosFuturosPageState extends State<PartidosFuturosPage> {
  
  // Lista para almacenar los partidos futuros
  final List<PartidoFuturo> _partidosFuturos = [];
  
  // Controladores para el formulario de partido futuro
  final _formFuturoKey = GlobalKey<FormState>();
  final _fechaFuturoController = TextEditingController();
  final _lugarController = TextEditingController();
  final _horaController = TextEditingController();
  final _equipoRivalController = TextEditingController();
  final _notasFuturoController = TextEditingController();
  
  // Variables de estado
  DateTime? _fechaPartidoFuturo;
  TimeOfDay? _horaPartidoFuturo;

  @override
  void initState() {
    super.initState();
    _cargarPartidosEjemplo(); // Cargar algunos datos de ejemplo
  }

  @override
  void dispose() {
    _fechaFuturoController.dispose();
    _lugarController.dispose();
    _horaController.dispose();
    _equipoRivalController.dispose();
    _notasFuturoController.dispose();
    super.dispose();
  }

  // Carga algunos partidos de ejemplo para demostrar la funcionalidad
  void _cargarPartidosEjemplo() {
    _partidosFuturos.addAll([
      PartidoFuturo(
        fecha: DateTime.now().add(const Duration(days: 3)),
        lugar: 'Estadio Santiago Bernabéu',
        hora: const TimeOfDay(hour: 16, minute: 0),
        equipoRival: 'Valencia CF',
        notas: 'Partido importante por la liga'
      ),
      PartidoFuturo(
        fecha: DateTime.now().add(const Duration(days: 10)),
        lugar: 'Camp Nou',
        hora: const TimeOfDay(hour: 20, minute: 30),
        equipoRival: 'Sevilla FC',
        notas: 'Clásico en casa, preparar táctica especial'
      ),
    ]);
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
        title: Text(
          'Partidos Futuros',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 20),
            // Botón para agregar nuevo partido futuro
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddButton(
                'Programar Partido',
                Icons.event_available,
                () => _mostrarFormularioPartidoFuturo(),
              ),
            ),
            const SizedBox(height: 20),
            // Lista de partidos futuros
            Expanded(
              child: _partidosFuturos.isEmpty
                  ? _buildEmptyState('No hay partidos programados', Icons.event)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _partidosFuturos.length,
                      itemBuilder: (context, index) {
                        return _buildPartidoFuturoCard(_partidosFuturos[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Construye el header dividido en dos secciones
  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
      child: Row(
        children: [
          // Sección Partidos Jugados (inactiva/navegable)
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Partidos Jugados',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Divisor
          Container(
            width: 1,
            height: 48,
            color: Colors.grey[300],
          ),
          // Sección Partidos Futuros (activa)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
                color: const Color(0xFF0065F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.event_available,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Partidos Futuros',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_partidosFuturos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Construye el botón de agregar
  Widget _buildAddButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF0065F8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0065F8).withOpacity(0.3),
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
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Estado vacío
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

  // Card de partido futuro
  Widget _buildPartidoFuturoCard(PartidoFuturo partido, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: const Color(0xFF0065F8).withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFF0065F8).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0065F8).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del partido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  partido.equipoRival,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              Icon(
                Icons.schedule,
                color: const Color(0xFF0065F8),
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Información del partido
          _buildInfoRow('Fecha', _formatDate(partido.fecha)),
          _buildInfoRow('Hora', _formatTime(partido.hora)),
          _buildInfoRow('Lugar', partido.lugar),
          if (partido.notas.isNotEmpty)
            _buildInfoRow('Notas', partido.notas),
          const SizedBox(height: 10),
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editarPartidoFuturo(partido, index),
                icon: const Icon(Icons.edit, color: Color(0xFF0065F8)),
              ),
              IconButton(
                onPressed: () => _eliminarPartidoFuturo(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Fila de información
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: value.length > 50 ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  // Muestra el formulario para programar partido futuro
  void _mostrarFormularioPartidoFuturo([PartidoFuturo? partido, int? index]) {
    if (partido != null) {
      _cargarDatosPartidoFuturo(partido);
    } else {
      _limpiarFormularioFuturo();
    }
    showDialog(
      context: context,
      builder: (context) => _buildFormularioPartidoFuturo(partido, index),
    );
  }

  // Formulario de partido futuro
  Widget _buildFormularioPartidoFuturo([PartidoFuturo? partido, int? index]) {
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
                color: const Color(0xFF0065F8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      partido != null ? 'Editar Partido' : 'Programar Partido',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
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
                  key: _formFuturoKey,
                  child: Column(
                    children: [
                      _buildCompactField(
                        'Fecha',
                        _fechaFuturoController,
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: () => _selectDateFuturo(),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Hora',
                        _horaController,
                        Icons.access_time,
                        readOnly: true,
                        onTap: () => _selectTimeFuturo(),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Lugar',
                        _lugarController,
                        Icons.location_on,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Equipo rival',
                        _equipoRivalController,
                        Icons.groups,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Notas',
                        _notasFuturoController,
                        Icons.note,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () => partido != null 
                              ? _actualizarPartidoFuturo(index!) 
                              : _guardarPartidoFuturo(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0065F8),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            partido != null ? 'Actualizar' : 'Programar',
                            style: const TextStyle(fontSize: 14),
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

  // Campo compacto para el Dialog
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
      style: const TextStyle(fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 16, color: const Color(0xFF0065F8)),
        labelStyle: const TextStyle(fontSize: 12, color: Color(0xFF0065F8)),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: Color(0xFF0065F8)),
        ),
        errorStyle: const TextStyle(fontSize: 10),
        isDense: true,
      ),
    );
  }

  // Validador
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  // Selectors de fecha y hora
  Future<void> _selectDateFuturo() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0065F8),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _fechaPartidoFuturo = picked;
        _fechaFuturoController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTimeFuturo() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 16, minute: 0),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF0065F8),
              onPrimary: Colors.white,
              surface: Color(0xFF1a1a2e),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _horaPartidoFuturo = picked;
        _horaController.text = _formatTime(picked);
      });
    }
  }

  // Método de guardado
  void _guardarPartidoFuturo() {
    if (_formFuturoKey.currentState?.validate() ?? false) {
      final partido = PartidoFuturo(
        fecha: _fechaPartidoFuturo!,
        lugar: _lugarController.text,
        hora: _horaPartidoFuturo!,
        equipoRival: _equipoRivalController.text,
        notas: _notasFuturoController.text,
      );

      setState(() {
        _partidosFuturos.add(partido);
        _partidosFuturos.sort((a, b) => a.fecha.compareTo(b.fecha));
      });

      Navigator.pop(context);
      _mostrarMensajeExito('Partido programado correctamente');
    }
  }

  // Método de actualización
  void _actualizarPartidoFuturo(int index) {
    if (_formFuturoKey.currentState?.validate() ?? false) {
      final partido = PartidoFuturo(
        fecha: _fechaPartidoFuturo!,
        lugar: _lugarController.text,
        hora: _horaPartidoFuturo!,
        equipoRival: _equipoRivalController.text,
        notas: _notasFuturoController.text,
      );

      setState(() {
        _partidosFuturos[index] = partido;
        _partidosFuturos.sort((a, b) => a.fecha.compareTo(b.fecha));
      });

      Navigator.pop(context);
      _mostrarMensajeExito('Partido actualizado correctamente');
    }
  }

  // Métodos de edición y eliminación
  void _editarPartidoFuturo(PartidoFuturo partido, int index) {
    _mostrarFormularioPartidoFuturo(partido, index);
  }

  void _eliminarPartidoFuturo(int index) {
    _mostrarDialogoConfirmacion(
      'Eliminar partido',
      '¿Estás seguro de que deseas eliminar este partido programado?',
      () {
        setState(() {
          _partidosFuturos.removeAt(index);
        });
        _mostrarMensajeExito('Partido eliminado');
      },
    );
  }

  // Métodos auxiliares
  void _limpiarFormularioFuturo() {
    _fechaFuturoController.clear();
    _lugarController.clear();
    _horaController.clear();
    _equipoRivalController.clear();
    _notasFuturoController.clear();
    _fechaPartidoFuturo = null;
    _horaPartidoFuturo = null;
  }

  void _cargarDatosPartidoFuturo(PartidoFuturo partido) {
    _fechaPartidoFuturo = partido.fecha;
    _fechaFuturoController.text = _formatDate(partido.fecha);
    _lugarController.text = partido.lugar;
    _horaPartidoFuturo = partido.hora;
    _horaController.text = _formatTime(partido.hora);
    _equipoRivalController.text = partido.equipoRival;
    _notasFuturoController.text = partido.notas;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarDialogoConfirmacion(String titulo, String mensaje, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          titulo, 
          style: TextStyle(color: Colors.grey[800]),
          overflow: TextOverflow.ellipsis,
        ),
        content: Text(
          mensaje, 
          style: TextStyle(color: Colors.grey[600]),
          overflow: TextOverflow.ellipsis,
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Modelo de datos para Partido Futuro
class PartidoFuturo {
  final DateTime fecha;
  final String lugar;
  final TimeOfDay hora;
  final String equipoRival;
  final String notas;

  PartidoFuturo({
    required this.fecha,
    required this.lugar,
    required this.hora,
    required this.equipoRival,
    required this.notas,
  });
}
