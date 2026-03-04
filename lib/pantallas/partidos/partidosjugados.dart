import 'package:flutter/material.dart';
import 'partidosfuturos.dart';
import '../../services/partidos_service.dart';
import '../../services/partidos_resultado_service.dart';

/// Pantalla principal para gestionar partidos jugados
class PartidosJugadosPage extends StatefulWidget {
  const PartidosJugadosPage({super.key});

  @override
  State<PartidosJugadosPage> createState() => _PartidosJugadosPageState();
}

class _PartidosJugadosPageState extends State<PartidosJugadosPage> {
  final List<PartidoJugado> _partidosJugados = [];
  bool _cargando = false;
  
  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _fechaController = TextEditingController();
  final _equipoContrarioController = TextEditingController();
  final _golesAFavorController = TextEditingController();
  final _golesEnContraController = TextEditingController();
  final _minutosController = TextEditingController();
  final _golesAnotadosController = TextEditingController();
  final _asistenciasController = TextEditingController();
  final _notasController = TextEditingController();
  
  String? _tarjetasSeleccionadas;
  DateTime? _fechaSeleccionada;


  final List<String> _tarjetas = [
    'Ninguna', 'Amarilla', 'Roja', 'Doble Amarilla'
  ];

  @override
  void initState() {
    super.initState();
    _cargarPartidos();
  }

  Future<void> _cargarPartidos() async {
    setState(() => _cargando = true);
    try {
      final resultado = await PartidosService.obtenerPartidosJugados();
      if (resultado['success'] == true && mounted) {
        final lista = resultado['partidos'] as List;
        setState(() {
          _partidosJugados
            ..clear()
            ..addAll(lista.map((p) {
              final res = p['resultado'] as Map<String, dynamic>? ?? {};
              final amarillas = (res['tarjetasAmarillas'] as int?) ?? 0;
              final rojas = (res['tarjetasRojas'] as int?) ?? 0;
              String tarjetas;
              if (rojas >= 1 && amarillas >= 2) {
                tarjetas = 'Doble Amarilla';
              } else if (rojas >= 1) {
                tarjetas = 'Roja';
              } else if (amarillas >= 1) {
                tarjetas = 'Amarilla';
              } else {
                tarjetas = 'Ninguna';
              }
              return PartidoJugado(
                id: p['_id'] as String?,
                fecha: DateTime.parse(p['fecha'] as String),
                equipoContrario: (p['equipoRival'] as String?) ?? '',
                golesAFavor: (res['golesLocal'] as int?) ?? 0,
                golesEnContra: (res['golesVisitante'] as int?) ?? 0,
                minutosJugados: (res['minutosJugados'] as int?) ?? 0,
                posicion: '',
                golesAnotados: (res['goles'] as int?) ?? 0,
                asistencias: (res['asistencias'] as int?) ?? 0,
                tarjetas: tarjetas,
                notas: (p['notas'] as String?) ?? '',
              );
            }))
            ..sort((a, b) => b.fecha.compareTo(a.fecha));
        });
      }
    } catch (e) {
      // silencioso en error de red
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _fechaController.dispose();
    _equipoContrarioController.dispose();
    _golesAFavorController.dispose();
    _golesEnContraController.dispose();
    _minutosController.dispose();
    _golesAnotadosController.dispose();
    _asistenciasController.dispose();
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
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Partidos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
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
                'Registrar Partido Jugado',
                Icons.add_box,
                () => _mostrarFormulario(),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _partidosJugados.isEmpty
                      ? _buildEmptyState('No hay partidos registrados', Icons.sports_soccer)
                      : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _partidosJugados.length,
                      itemBuilder: (context, index) {
                        return _buildPartidoCard(_partidosJugados[index], index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // =============== Widgets de UI ===============
  
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
            color: Colors.grey.withValues(alpha: 0.1),
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
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1a1a2e),
                    Color(0xFF16213e),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    color: Color(0xFF00f5ff),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Jugados',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00f5ff),
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
                      color: const Color(0xFF1a1a2e),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Próximos',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1a1a2e),
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

  void _navegarAPartidosFuturos() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PartidosFuturosPage(),
      ),
    );
  }

  Widget _buildAddButton(String text, IconData icon, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF1565C0),
            Color(0xFF1E88E5),
            Color(0xFF42A5F5),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.55),
            blurRadius: 14,
            spreadRadius: 1,
            offset: const Offset(0, 5),
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
                  letterSpacing: 0.5,
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

  Widget _buildPartidoCard(PartidoJugado partido, int index) {
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
            color: const Color(0xFF00f5ff).withValues(alpha: 0.08),
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
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
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
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1a1a2e),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1a1a2e),
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: value.length > 50 ? 2 : 1,
            ),
          ),
        ],
      ),
    );
  }

  // =============== Formularios ===============
  
  void _mostrarFormulario([PartidoJugado? partido, int? index]) {
    if (partido != null) {
      _cargarDatos(partido);
    } else {
      _limpiarFormulario();
    }
    showDialog(
      context: context,
      builder: (context) => _buildFormulario(partido, index),
    );
  }

  Widget _buildFormulario([PartidoJugado? partido, int? index]) {
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
                      partido != null ? 'Editar Partido' : 'Registrar Partido',
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
                        onTap: () => _selectDate(),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Equipo contrario',
                        _equipoContrarioController,
                        Icons.groups,
                        validator: _validateRequired,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              'Goles a favor',
                              _golesAFavorController,
                              Icons.sports_soccer,
                              keyboardType: TextInputType.number,
                              validator: _validateNumber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildCompactField(
                              'Goles en contra',
                              _golesEnContraController,
                              Icons.sports_soccer,
                              keyboardType: TextInputType.number,
                              validator: _validateNumber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildCompactField(
                        'Minutos',
                        _minutosController,
                        Icons.timer,
                        keyboardType: TextInputType.number,
                        validator: _validateMinutes,
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Expanded(
                            child: _buildCompactField(
                              'Goles',
                              _golesAnotadosController,
                              Icons.sports_soccer,
                              keyboardType: TextInputType.number,
                              validator: _validateNumber,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _buildCompactField(
                              'Asistencias',
                              _asistenciasController,
                              Icons.sports_soccer,
                              keyboardType: TextInputType.number,
                              validator: _validateNumber,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _buildCompactDropdown(
                        'Tarjetas',
                        _tarjetasSeleccionadas,
                        _tarjetas,
                        (value) => setState(() => _tarjetasSeleccionadas = value),
                        Icons.credit_card,
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
                          onPressed: () => _guardarPartido(partidoEditar: partido, index: index),
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
                            partido != null ? 'Actualizar' : 'Guardar',
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

  // =============== Lógica de datos ===============
  
  Future<void> _selectDate() async {
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
        _fechaSeleccionada = picked;
        _fechaController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _guardarPartido({PartidoJugado? partidoEditar, int? index}) async {
    if (_formKey.currentState?.validate() ?? false) {
      final tarjetaStr = _tarjetasSeleccionadas ?? 'Ninguna';
      int amarillas = 0, rojas = 0;
      if (tarjetaStr == 'Amarilla') { amarillas = 1; }
      else if (tarjetaStr == 'Doble Amarilla') { amarillas = 2; rojas = 1; }
      else if (tarjetaStr == 'Roja') { rojas = 1; }

      if (partidoEditar != null && index != null) {
        // Edición: actualizar en el backend
        final id = partidoEditar.id;
        if (id != null) {
          await PartidosService.actualizarPartido(
            partidoId: id,
            equipoRival: _equipoContrarioController.text,
            fecha: _fechaSeleccionada,
            lugar: '-',
          );
          await PartidosResultadoService.registrarResultado(
            partidoId: id,
            golesLocal: int.parse(_golesAFavorController.text),
            golesVisitante: int.parse(_golesEnContraController.text),
            goles: int.parse(_golesAnotadosController.text),
            asistencias: int.parse(_asistenciasController.text),
            tarjetasAmarillas: amarillas,
            tarjetasRojas: rojas,
            minutosJugados: int.parse(_minutosController.text),
          );
        }
        if (!mounted) return;
        final partido = PartidoJugado(
          id: partidoEditar.id,
          fecha: _fechaSeleccionada!,
          equipoContrario: _equipoContrarioController.text,
          golesAFavor: int.parse(_golesAFavorController.text),
          golesEnContra: int.parse(_golesEnContraController.text),
          minutosJugados: int.parse(_minutosController.text),
          posicion: '',
          golesAnotados: int.parse(_golesAnotadosController.text),
          asistencias: int.parse(_asistenciasController.text),
          tarjetas: tarjetaStr,
          notas: _notasController.text,
        );
        setState(() {
          _partidosJugados[index] = partido;
          _partidosJugados.sort((a, b) => b.fecha.compareTo(a.fecha));
        });
        Navigator.pop(context);
        _mostrarMensajeExito('Partido actualizado correctamente');
        return;
      }

      // Nuevo partido: guardar en API
      final crearRes = await PartidosService.crearPartido(
        equipoRival: _equipoContrarioController.text,
        fecha: _fechaSeleccionada!,
        hora: '00:00',
        lugar: '-',
      );

      if (!mounted) return;

      if (crearRes['success'] != true) {
        _mostrarMensajeExito('Error al registrar: ${crearRes['message']}');
        return;
      }

      final partidoId = crearRes['partido']['_id'] as String;

      // Registrar resultado
      final resultRes = await PartidosResultadoService.registrarResultado(
        partidoId: partidoId,
        golesLocal: int.parse(_golesAFavorController.text),
        golesVisitante: int.parse(_golesEnContraController.text),
        goles: int.parse(_golesAnotadosController.text),
        asistencias: int.parse(_asistenciasController.text),
        tarjetasAmarillas: amarillas,
        tarjetasRojas: rojas,
        minutosJugados: int.parse(_minutosController.text),
      );

      if (!mounted) return;

      if (resultRes['success'] == true) {
        Navigator.pop(context);
        _mostrarMensajeExito('Partido registrado correctamente');
        _cargarPartidos();
      } else {
        _mostrarMensajeExito('Error al registrar resultado: ${resultRes['message']}');
      }
    }
  }

  // Método de eliminación
  void _eliminarPartido(int index) {
    _mostrarDialogoConfirmacion(
      'Eliminar partido',
      '¿Estás seguro de que deseas eliminar este partido?',
      () async {
        final id = _partidosJugados[index].id;
        if (id != null) {
          await PartidosService.eliminarPartido(id);
        }
        if (mounted) {
          setState(() => _partidosJugados.removeAt(index));
          _mostrarMensajeExito('Partido eliminado');
        }
      },
    );
  }

  void _editarPartido(PartidoJugado partido, int index) {
    _mostrarFormulario(partido, index);
  }

  void _cargarDatos(PartidoJugado partido) {
    _fechaSeleccionada = partido.fecha;
    _fechaController.text = _formatDate(partido.fecha);
    _equipoContrarioController.text = partido.equipoContrario;
    _golesAFavorController.text = partido.golesAFavor.toString();
    _golesEnContraController.text = partido.golesEnContra.toString();
    _minutosController.text = partido.minutosJugados.toString();
    _golesAnotadosController.text = partido.golesAnotados.toString();
    _asistenciasController.text = partido.asistencias.toString();
    _tarjetasSeleccionadas = partido.tarjetas;
    _notasController.text = partido.notas;
  }

  void _limpiarFormulario() {
    _fechaController.clear();
    _equipoContrarioController.clear();
    _golesAFavorController.text = '0';
    _golesEnContraController.text = '0';
    _minutosController.text = '90';
    _golesAnotadosController.text = '0';
    _asistenciasController.text = '0';
    _notasController.clear();
    _tarjetasSeleccionadas = 'Ninguna';
    _fechaSeleccionada = null;
  }

  // =============== Métodos auxiliares ===============
  
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

class PartidoJugado {
  final String? id;
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
    this.id,
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
