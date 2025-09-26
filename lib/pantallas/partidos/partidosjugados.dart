import 'package:flutter/material.dart';
import 'partidosfuturos.dart';

/// Pantalla de partidos jugados de Soccer Life
/// Permite registrar y gestionar partidos ya jugados
class PartidosJugadosPage extends StatefulWidget {
  const PartidosJugadosPage({super.key});

  @override
  State<PartidosJugadosPage> createState() => _PartidosJugadosPageState();
}

class _PartidosJugadosPageState extends State<PartidosJugadosPage> {
  
  // Lista para almacenar los partidos jugados
  final List<PartidoJugado> _partidosJugados = [];
  
  // Controladores para el formulario de partido jugado
  final _formJugadoKey = GlobalKey<FormState>();
  final _fechaJugadoController = TextEditingController();
  final _equipoContrarioJugadoController = TextEditingController();
  final _golesAFavorController = TextEditingController();
  final _golesEnContraController = TextEditingController();
  final _minutosJugadosController = TextEditingController();
  final _golesAnotadosController = TextEditingController();
  final _asistenciasController = TextEditingController();
  final _notasJugadoController = TextEditingController();
  
  // Variables para los dropdowns
  String? _posicionSeleccionada;
  String? _tarjetasSeleccionadas;
  
  // Variable de estado
  DateTime? _fechaPartidoJugado;

  final List<String> _posiciones = [
    'Arquero', 'Defensa Central', 'Lateral Derecho', 'Lateral Izquierdo',
    'Volante Defensivo', 'Volante Central', 'Volante Ofensivo',
    'Extremo Derecho', 'Extremo Izquierdo', 'Delantero', 'Segundo Delantero'
  ];

  final List<String> _tarjetas = [
    'Ninguna', 'Amarilla', 'Roja', 'Doble Amarilla'
  ];

  @override
  void initState() {
    super.initState();
    _cargarPartidosEjemplo(); // Cargar algunos datos de ejemplo
  }

  @override
  void dispose() {
    _fechaJugadoController.dispose();
    _equipoContrarioJugadoController.dispose();
    _golesAFavorController.dispose();
    _golesEnContraController.dispose();
    _minutosJugadosController.dispose();
    _golesAnotadosController.dispose();
    _asistenciasController.dispose();
    _notasJugadoController.dispose();
    super.dispose();
  }

  // Carga algunos partidos de ejemplo para demostrar la funcionalidad
  void _cargarPartidosEjemplo() {
    _partidosJugados.addAll([
      PartidoJugado(
        fecha: DateTime.now().subtract(const Duration(days: 7)),
        equipoContrario: 'Real Madrid CF',
        golesAFavor: 2,
        golesEnContra: 1,
        minutosJugados: 90,
        posicion: 'Delantero',
        golesAnotados: 1,
        asistencias: 1,
        tarjetas: 'Amarilla',
        notas: 'Buen partido, marcamos en el último minuto'
      ),
      PartidoJugado(
        fecha: DateTime.now().subtract(const Duration(days: 14)),
        equipoContrario: 'FC Barcelona',
        golesAFavor: 1,
        golesEnContra: 3,
        minutosJugados: 75,
        posicion: 'Extremo Derecho',
        golesAnotados: 0,
        asistencias: 1,
        tarjetas: 'Ninguna',
        notas: 'Partido difícil, nos superaron en el medio campo'
      ),
      PartidoJugado(
        fecha: DateTime.now().subtract(const Duration(days: 21)),
        equipoContrario: 'Atlético Madrid',
        golesAFavor: 0,
        golesEnContra: 0,
        minutosJugados: 90,
        posicion: 'Volante Central',
        golesAnotados: 0,
        asistencias: 0,
        tarjetas: 'Amarilla',
        notas: 'Empate defensivo, poca ocasiones de gol'
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
          'Partidos Jugados',
          style: TextStyle(
            color: Colors.grey[800],
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.event_available, color: const Color(0xFF0065F8)),
            onPressed: () => _navegarAPartidosFuturos(),
            tooltip: 'Partidos Futuros',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Header con navegación a partidos futuros
            _buildHeader(),
            const SizedBox(height: 20),
            // Botón para agregar nuevo partido jugado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildAddButton(
                'Registrar Partido Jugado',
                Icons.add_box,
                () => _mostrarFormularioPartidoJugado(),
              ),
            ),
            const SizedBox(height: 20),
            // Lista de partidos jugados
            Expanded(
              child: _partidosJugados.isEmpty
                  ? _buildEmptyState('No hay partidos registrados', Icons.sports_soccer)
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _partidosJugados.length,
                      itemBuilder: (context, index) {
                        return _buildPartidoJugadoCard(_partidosJugados[index], index);
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
          // Sección Partidos Jugados (activa)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                color: const Color(0xFF0065F8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Partidos Jugados',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Divisor
          Container(
            width: 1,
            height: 48,
            color: Colors.grey[300],
          ),
          // Sección Partidos Futuros (inactiva/navegable)
          Expanded(
            child: GestureDetector(
              onTap: _navegarAPartidosFuturos,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(right: Radius.circular(15)),
                  color: Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_available,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Partidos Futuros',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
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

  // Navegar a partidos futuros
  void _navegarAPartidosFuturos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PartidosFuturosPage(),
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
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
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
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Card de partido jugado
  Widget _buildPartidoJugadoCard(PartidoJugado partido, int index) {
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
          // Header del partido
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  partido.equipoContrario,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Text(
                '${partido.golesAFavor} - ${partido.golesEnContra}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: partido.golesAFavor > partido.golesEnContra
                      ? Colors.green
                      : partido.golesAFavor == partido.golesEnContra
                          ? Colors.orange
                          : Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Fecha
          _buildInfoRow('Fecha', _formatDate(partido.fecha)),
          _buildInfoRow('Posición', partido.posicion),
          _buildInfoRow('Minutos jugados', '${partido.minutosJugados}\''),
          _buildInfoRow('Goles anotados', partido.golesAnotados.toString()),
          _buildInfoRow('Asistencias', partido.asistencias.toString()),
          _buildInfoRow('Tarjetas', partido.tarjetas),
          if (partido.notas.isNotEmpty)
            _buildInfoRow('Notas', partido.notas),
          const SizedBox(height: 10),
          // Botones de acción
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _eliminarPartidoJugado(index),
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
            width: 120,
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
            ),
          ),
        ],
      ),
    );
  }

  // Muestra el formulario para registrar partido jugado
  void _mostrarFormularioPartidoJugado() {
    _limpiarFormularioJugado();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFormularioPartidoJugado(),
    );
  }

  // Formulario de partido jugado
  Widget _buildFormularioPartidoJugado() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle del modal
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 50,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registrar Partido Jugado',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formJugadoKey,
                child: Column(
                  children: [
                    _buildDateField(
                      'Fecha del partido',
                      _fechaJugadoController,
                      () => _selectDateJugado(),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Equipo contrario',
                      _equipoContrarioJugadoController,
                      'Nombre del equipo rival',
                      Icons.groups,
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Goles a favor',
                            _golesAFavorController,
                            '0',
                            Icons.sports_soccer,
                            keyboardType: TextInputType.number,
                            validator: _validateNumber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Goles en contra',
                            _golesEnContraController,
                            '0',
                            Icons.sports_soccer,
                            keyboardType: TextInputType.number,
                            validator: _validateNumber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Minutos jugados',
                      _minutosJugadosController,
                      '90',
                      Icons.timer,
                      keyboardType: TextInputType.number,
                      validator: _validateMinutes,
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Posición jugada',
                      _posicionSeleccionada,
                      _posiciones,
                      (value) => setState(() => _posicionSeleccionada = value),
                      Icons.person,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            'Goles anotados',
                            _golesAnotadosController,
                            '0',
                            Icons.sports_soccer,
                            keyboardType: TextInputType.number,
                            validator: _validateNumber,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            'Asistencias',
                            _asistenciasController,
                            '0',
                            Icons.sports_soccer,
                            keyboardType: TextInputType.number,
                            validator: _validateNumber,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      'Tarjetas recibidas',
                      _tarjetasSeleccionadas,
                      _tarjetas,
                      (value) => setState(() => _tarjetasSeleccionadas = value),
                      Icons.credit_card,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      'Notas adicionales',
                      _notasJugadoController,
                      'Comentarios del partido...',
                      Icons.note,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),
                    _buildSubmitButton('Guardar Partido', _guardarPartidoJugado),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Campo de texto personalizado
  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF0065F8)),
        labelStyle: const TextStyle(color: Color(0xFF0065F8)),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0065F8)),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  // Campo de fecha
  Widget _buildDateField(String label, TextEditingController controller, VoidCallback onTap) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      validator: (value) => value?.isEmpty ?? true ? 'Selecciona una fecha' : null,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Seleccionar fecha',
        prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF0065F8)),
        suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0065F8)),
        labelStyle: const TextStyle(color: Color(0xFF0065F8)),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A8A)),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
    );
  }

  // Campo dropdown personalizado
  Widget _buildDropdownField(
    String label,
    String? value,
    List<String> items,
    void Function(String?) onChanged,
    IconData icon,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      validator: (value) => value == null ? 'Selecciona una opción' : null,
      dropdownColor: Colors.white,
      style: TextStyle(color: Colors.grey[800]),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF0065F8)),
        labelStyle: const TextStyle(color: Color(0xFF0065F8)),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0065F8)),
        ),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  // Botón de envío
  Widget _buildSubmitButton(String text, VoidCallback onPressed) {
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
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Validadores
  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    return null;
  }

  String? _validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    if (int.tryParse(value) == null) {
      return 'Ingresa un número válido';
    }
    if (int.parse(value) < 0) {
      return 'El número debe ser positivo';
    }
    return null;
  }

  String? _validateMinutes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio';
    }
    final minutes = int.tryParse(value);
    if (minutes == null) {
      return 'Ingresa un número válido';
    }
    if (minutes < 0 || minutes > 120) {
      return 'Los minutos deben estar entre 0 y 120';
    }
    return null;
  }

  // Selector de fecha
  Future<void> _selectDateJugado() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
        _fechaPartidoJugado = picked;
        _fechaJugadoController.text = _formatDate(picked);
      });
    }
  }

  // Método de guardado
  void _guardarPartidoJugado() {
    if (_formJugadoKey.currentState?.validate() ?? false) {
      final partido = PartidoJugado(
        fecha: _fechaPartidoJugado!,
        equipoContrario: _equipoContrarioJugadoController.text,
        golesAFavor: int.parse(_golesAFavorController.text),
        golesEnContra: int.parse(_golesEnContraController.text),
        minutosJugados: int.parse(_minutosJugadosController.text),
        posicion: _posicionSeleccionada!,
        golesAnotados: int.parse(_golesAnotadosController.text),
        asistencias: int.parse(_asistenciasController.text),
        tarjetas: _tarjetasSeleccionadas!,
        notas: _notasJugadoController.text,
      );

      setState(() {
        _partidosJugados.add(partido);
        _partidosJugados.sort((a, b) => b.fecha.compareTo(a.fecha));
      });

      Navigator.pop(context);
      _mostrarMensajeExito('Partido registrado correctamente');
    }
  }

  // Método de eliminación
  void _eliminarPartidoJugado(int index) {
    _mostrarDialogoConfirmacion(
      'Eliminar partido',
      '¿Estás seguro de que deseas eliminar este partido?',
      () {
        setState(() {
          _partidosJugados.removeAt(index);
        });
        _mostrarMensajeExito('Partido eliminado');
      },
    );
  }

  // Métodos auxiliares
  void _limpiarFormularioJugado() {
    _fechaJugadoController.clear();
    _equipoContrarioJugadoController.clear();
    _golesAFavorController.text = '0';
    _golesEnContraController.text = '0';
    _minutosJugadosController.text = '90';
    _golesAnotadosController.text = '0';
    _asistenciasController.text = '0';
    _notasJugadoController.clear();
    _posicionSeleccionada = null;
    _tarjetasSeleccionadas = 'Ninguna';
    _fechaPartidoJugado = null;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
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

// Modelo de datos para Partido Jugado
class PartidoJugado {
  final DateTime fecha;
  final String equipoContrario;
  final int golesAFavor;
  final int golesEnContra;
  final int minutosJugados;
  final String posicion;
  final int golesAnotados;
  final int asistencias;
  final String tarjetas;
  final String notas;

  PartidoJugado({
    required this.fecha,
    required this.equipoContrario,
    required this.golesAFavor,
    required this.golesEnContra,
    required this.minutosJugados,
    required this.posicion,
    required this.golesAnotados,
    required this.asistencias,
    required this.tarjetas,
    required this.notas,
  });
}
