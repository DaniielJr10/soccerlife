import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/cv_option_card.dart';
import 'pdf_upload_page.dart';
import 'fifa_card_page.dart';

/// Página principal de CV Deportivo — dos opciones disponibles.
class HojaDeVidaPage extends StatelessWidget {
  const HojaDeVidaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('CV Deportivo'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildHeader(),
            const SizedBox(height: 28),
            CvOptionCard(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Subir CV en PDF',
              subtitle: 'Carga tu hoja de vida deportiva en formato PDF',
              accentColor: const Color(0xFFEF4444),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PdfUploadPage()),
              ),
            ),
            const SizedBox(height: 16),
            CvOptionCard(
              icon: Icons.style_rounded,
              title: 'Crear Carta FIFA',
              subtitle: 'Diseña tu tarjeta personalizada estilo FIFA Ultimate Team',
              accentColor: const Color(0xFFFFD700),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FifaCardPage()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sports_soccer_rounded,
                  color: AppColors.primary, size: 14),
              const SizedBox(width: 6),
              Text(
                'SoccerLife',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Tu identidad\ndeportiva',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Presenta tu perfil como profesional',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }
}
