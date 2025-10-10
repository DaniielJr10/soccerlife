import 'package:flutter/material.dart';

/// Pantalla de partidos futuros - permite programar y gestionar partidos próximos
class PartidosFuturosPage extends StatefulWidget {
  const PartidosFuturosPage({super.key});

  @override
  State<PartidosFuturosPage> createState() => _PartidosFuturosPageState();
}

class _PartidosFuturosPageState extends State<PartidosFuturosPage> {
  // Variables principales
  final List<PartidoFuturo> _partidosFuturos = [];
  
  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _lugarController = TextEditingController();
  final _horaController = TextEditingController();
  final _equipoRivalController = TextEditingController();
  final _notasController = TextEditingController();
  
  // Estado temporal del formulario
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;

  @override
  void initState() {
    super.initState();
    _cargarDatosEjemplo();
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _lugarController.dispose();
    _horaController.dispose();
    _equipoRivalController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _cargarDatosEjemplo() {
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
            _buildHeader(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddButton(
                'Programar Partido',
                Icons.event_available,
                () => _mostrarFormulario(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _partidosFuturos.isEmpty
                  ? _buildEmptyState('No hay partidos programados', Icons.event)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _partidosFuturos.length,
                      itemBuilder: (context, index) {
                        return _buildPartidoCard(_partidosFuturos[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Widgets de construcción de la UI
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
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(15)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.sports_soccer, color: Colors.grey[600], size: 20),
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
          Container(width: 1, height: 48, color: Colors.grey[300]),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.horizontal(right: Radius.circular(15)),
                color: Color(0xFF0065F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.event_available, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Flexible(
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildPartidoCard(PartidoFuturo partido, int index) {
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
              const Icon(Icons.schedule, color: Color(0xFF0065F8), size: 24),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Fecha', _formatDate(partido.fecha)),
          _buildInfoRow('Hora', _formatTime(partido.hora)),
          _buildInfoRow('Lugar', partido.lugar),
          if (partido.notas.isNotEmpty)
            _buildInfoRow('Notas', partido.notas),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _editarPartido(partido, index),
                icon: const Icon(Icons.edit, color: Color(0xFF0065F8)),
              ),
              IconButton(
                onPressed: () => _eliminarPartido(index),
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
              style: TextStyle(fontSize: 14, color: Colors.grey[800]),
              overflow: TextOverflow.ellipsis,
              maxLines: value.length > 50 ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  // Formulario de partido
  void _mostrarFormulario([PartidoFuturo? partido, int? index]) {
    if (partido != null) {
      _cargarDatosFormulario(partido);
    } else {
      _limpiarFormulario();
    }
    showDialog(
      context: context,
      builder: (context) => _buildFormulario(partido, index),
    );
  }

  Widget _buildFormulario([PartidoFuturo? partido, int? index]) {
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
            _buildFormularioHeader(partido),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildCampo(
                        'Fecha',
                        _fechaController,
                        Icons.calendar_today,
                        readOnly: true,
                        onTap: _seleccionarFecha,
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCampo(
                        'Hora',
                        _horaController,
                        Icons.access_time,
                        readOnly: true,
                        onTap: _seleccionarHora,
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCampo(
                        'Lugar',
                        _lugarController,
                        Icons.location_on,
                        validator: _validarRequerido,
                      ),
                      const SizedBox(height: 6),
                      _buildCampo(
                        'Equipo rival',
                        _equipoRivalController,
                        Icons.groups,
                        validator: _validarRequerido,
                      ),
                      const SizedBox(height: 6),
                      _buildCampo(
                        'Notas',
                        _notasController,
                        Icons.note,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      _buildBotonFormulario(partido, index),
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

  Widget _buildFormularioHeader(PartidoFuturo? partido) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Color(0xFF0065F8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
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
    );
  }

  Widget _buildBotonFormulario(PartidoFuturo? partido, int? index) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: ElevatedButton(
        onPressed: () => partido != null 
            ? _actualizarPartido(index!) 
            : _guardarPartido(),
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
    );
  }

  Widget _buildCampo(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? validator,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
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

  // Funciones de validación y selección
  String? _validarRequerido(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  Future<void> _seleccionarFecha() async {
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
        _fechaSeleccionada = picked;
        _fechaController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _seleccionarHora() async {
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
        _horaSeleccionada = picked;
        _horaController.text = _formatTime(picked);
      });
    }
  }

  // Funciones de gestión de datos
  void _guardarPartido() {
    if (_formKey.currentState?.validate() ?? false) {
      final partido = PartidoFuturo(
        fecha: _fechaSeleccionada!,
        lugar: _lugarController.text,
        hora: _horaSeleccionada!,
        equipoRival: _equipoRivalController.text,
        notas: _notasController.text,
      );

      setState(() {
        _partidosFuturos.add(partido);
        _partidosFuturos.sort((a, b) => a.fecha.compareTo(b.fecha));
      });

      Navigator.pop(context);
      _mostrarMensaje('Partido programado correctamente');
    }
  }

  void _actualizarPartido(int index) {
    if (_formKey.currentState?.validate() ?? false) {
      final partido = PartidoFuturo(
        fecha: _fechaSeleccionada!,
        lugar: _lugarController.text,
        hora: _horaSeleccionada!,
        equipoRival: _equipoRivalController.text,
        notas: _notasController.text,
      );

      setState(() {
        _partidosFuturos[index] = partido;
        _partidosFuturos.sort((a, b) => a.fecha.compareTo(b.fecha));
      });

      Navigator.pop(context);
      _mostrarMensaje('Partido actualizado correctamente');
    }
  }

  void _editarPartido(PartidoFuturo partido, int index) {
    _mostrarFormulario(partido, index);
  }

  void _eliminarPartido(int index) {
    _mostrarDialogoConfirmacion(
      'Eliminar partido',
      '¿Estás seguro de que deseas eliminar este partido programado?',
      () {
        setState(() {
          _partidosFuturos.removeAt(index);
        });
        _mostrarMensaje('Partido eliminado');
      },
    );
  }

  // Funciones auxiliares
  void _limpiarFormulario() {
    _fechaController.clear();
    _lugarController.clear();
    _horaController.clear();
    _equipoRivalController.clear();
    _notasController.clear();
    _fechaSeleccionada = null;
    _horaSeleccionada = null;
  }

  void _cargarDatosFormulario(PartidoFuturo partido) {
    _fechaSeleccionada = partido.fecha;
    _fechaController.text = _formatDate(partido.fecha);
    _lugarController.text = partido.lugar;
    _horaSeleccionada = partido.hora;
    _horaController.text = _formatTime(partido.hora);
    _equipoRivalController.text = partido.equipoRival;
    _notasController.text = partido.notas;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _mostrarMensaje(String mensaje) {
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
        title: Text(titulo, style: TextStyle(color: Colors.grey[800])),
        content: Text(mensaje, style: TextStyle(color: Colors.grey[600])),
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

// Modelo de datos
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
