import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/fifa_card_service.dart';
import '../../domain/entities/fifa_card_entity.dart';
import '../widgets/fifa_card_widget.dart';
import '../widgets/fifa_stats_form.dart';

/// Página de creación de Carta FIFA.
/// Tab 0 → Formulario editable.
/// Tab 1 → Vista previa de la carta generada.
class FifaCardPage extends StatefulWidget {
  const FifaCardPage({super.key});

  @override
  State<FifaCardPage> createState() => _FifaCardPageState();
}

class _FifaCardPageState extends State<FifaCardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  FifaCardEntity _card = FifaCardEntity.initial();

  bool _isLoading = true;
  bool _isSaving  = false;
  bool _cartaExiste = false; // true si el servidor ya tiene una carta guardada

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _cargarCarta();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  // ── Carga desde MongoDB ──────────────────────────────────────────────────

  Future<void> _cargarCarta() async {
    setState(() => _isLoading = true);
    final result = await FifaCardService.obtenerCarta();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success && result.carta != null) {
        _card = result.carta!;
        _cartaExiste = true;
      }
    });
  }

  // ── Guardar en MongoDB ───────────────────────────────────────────────────

  Future<void> _guardarCarta() async {
    setState(() => _isSaving = true);
    final result = await FifaCardService.guardarCarta(_card);
    if (!mounted) return;
    setState(() { _isSaving = false; _cartaExiste = true; });
    _mostrarSnack(
      result.message ?? (result.success ? 'Guardado' : 'Error'),
      result.success,
    );
  }

  // ── Eliminar de MongoDB ──────────────────────────────────────────────────

  Future<void> _confirmarEliminar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar carta',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            '¿Estás seguro de que quieres eliminar tu Carta FIFA? Esta acción no se puede deshacer.',
            style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: Color(0xFFEF4444)))),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isSaving = true);
    final result = await FifaCardService.eliminarCarta();
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (result.success) {
        _card = FifaCardEntity.initial();
        _cartaExiste = false;
      }
    });
    _mostrarSnack(result.message ?? 'Error', result.success);
  }

  void _mostrarSnack(String msg, bool ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: ok ? AppColors.success : AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carta FIFA'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_cartaExiste && !_isSaving)
            IconButton(
              tooltip: 'Eliminar carta',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFEF4444)),
              onPressed: _confirmarEliminar,
            ),
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFFFD700)),
              ),
            )
          else
            TextButton.icon(
              onPressed: _guardarCarta,
              icon: const Icon(Icons.cloud_upload_rounded,
                  color: Color(0xFFFFD700), size: 18),
              label: const Text('Guardar',
                  style: TextStyle(
                      color: Color(0xFFFFD700), fontWeight: FontWeight.w700)),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.edit_rounded), text: 'Editar'),
            Tab(icon: Icon(Icons.style_rounded), text: 'Vista previa'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : TabBarView(
              controller: _tabs,
              children: [
                FifaStatsForm(
                  initial: _card,
                  onChanged: (updated) => setState(() => _card = updated),
                ),
                _PreviewTab(card: _card),
              ],
            ),
    );
  }
}

// ── Pestaña de Vista Previa ───────────────────────────────────────────────────
class _PreviewTab extends StatelessWidget {
  final FifaCardEntity card;

  const _PreviewTab({required this.card});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        children: [
          _buildCardPreview(context),
          const SizedBox(height: 32),
          _buildContactInfo(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCardPreview(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width - 48;
    final cardW = maxW.clamp(200.0, 300.0);
    return Center(child: FifaCardWidget(card: card, width: cardW));
  }

  Widget _buildContactInfo() {
    if (card.contacto.isEmpty && card.club.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'INFORMACIÓN DE CONTACTO',
            style: TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          if (card.club.isNotEmpty)
            _infoRow(Icons.shield_rounded, card.club),
          if (card.contacto.isNotEmpty)
            _infoRow(Icons.alternate_email_rounded, card.contacto),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFFD700), size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
          ],
        ),
      );
}
