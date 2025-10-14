import 'package:flutter/material.dart';

/// Pantalla de estadísticas que muestra diferentes tipos de datos deportivos
/// Incluye estadísticas individuales, de equipo, logros y habilidades del jugador
class EstadisticasPage extends StatefulWidget {
  const EstadisticasPage({super.key});

  @override
  State<EstadisticasPage> createState() => _EstadisticasPageState();
}

class _EstadisticasPageState extends State<EstadisticasPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Estadísticas',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a2e),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildGridEstadisticas(),
            ],
          ),
        ),
      ),
    );
  }

  // ...el resto del código permanece igual...

  /// Construye el grid con las 4 tarjetas de estadísticas
  Widget _buildGridEstadisticas() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 0.85,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      children: [
        _buildTarjetaEstadistica(
          titulo: 'Estadísticas\nIndividuales',
          icono: Icons.person,
          descripcion: 'Goles, asistencias,\ny más datos personales',
          onTap: () => _navegarAEstadisticasIndividuales(),
        ),
        _buildTarjetaEstadistica(
          titulo: 'Estadísticas\nde Equipo',
          icono: Icons.groups,
          descripcion: 'Rendimiento colectivo\ny comparativas',
          onTap: () => _navegarAEstadisticasEquipo(),
        ),
        _buildTarjetaEstadistica(
          titulo: 'Logros',
          icono: Icons.emoji_events,
          descripcion: 'Trofeos, medallas\ny reconocimientos',
          onTap: () => _navegarALogros(),
        ),
        _buildTarjetaEstadistica(
          titulo: 'Habilidades',
          icono: Icons.star,
          descripcion: 'Técnica, físico\ny habilidades especiales',
          onTap: () => _navegarAHabilidades(),
        ),
      ],
    );
  }

  /// Construye cada tarjeta individual de estadística
  /// Recibe el título, ícono, descripción y función de navegación
  Widget _buildTarjetaEstadistica({
    required String titulo,
    required IconData icono,
    required String descripcion,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00f5ff),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0065F8).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1a1a2e),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1a1a2e).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icono,
                color: const Color(0xFF00f5ff),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1a1a2e),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              descripcion,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  /// Navega a la pantalla de estadísticas individuales
  void _navegarAEstadisticasIndividuales() {
    // TODO: Implementar navegación a estadísticas individuales
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estadísticas Individuales - Próximamente'),
        backgroundColor: Color(0xFF1a1a2e),
      ),
    );
  }

  /// Navega a la pantalla de estadísticas de equipo
  void _navegarAEstadisticasEquipo() {
    // TODO: Implementar navegación a estadísticas de equipo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Estadísticas de Equipo - Próximamente'),
        backgroundColor: Color(0xFF1a1a2e),
      ),
    );
  }

  /// Navega a la pantalla de logros
  void _navegarALogros() {
    // TODO: Implementar navegación a logros
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logros - Próximamente'),
        backgroundColor: Color(0xFF1a1a2e),
      ),
    );
  }

  /// Navega a la pantalla de habilidades
  void _navegarAHabilidades() {
    // TODO: Implementar navegación a habilidades
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Habilidades - Próximamente'),
        backgroundColor: Color(0xFF1a1a2e),
      ),
    );
  }
}
