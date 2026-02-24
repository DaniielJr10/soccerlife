import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Carta FIFA'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
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
      body: TabBarView(
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
