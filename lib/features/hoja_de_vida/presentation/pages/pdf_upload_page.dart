import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';

/// Página para cargar el CV deportivo en formato PDF.
class PdfUploadPage extends StatefulWidget {
  const PdfUploadPage({super.key});

  @override
  State<PdfUploadPage> createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  bool _uploadDone = false;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedFile = result.files.first;
        _uploadDone = false;
      });
    }
  }

  Future<void> _simularSubida() async {
    if (_selectedFile == null) return;
    setState(() => _isUploading = true);
    // Simulación de subida — conectar al backend real aquí
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() { _isUploading = false; _uploadDone = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Subir CV en PDF'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            _buildDropZone(),
            const SizedBox(height: 24),
            if (_selectedFile != null) _buildFileInfo(),
            if (_uploadDone) _buildSuccessBanner(),
            const Spacer(),
            _buildUploadButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDropZone() {
    return GestureDetector(
      onTap: _pickPdf,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedFile != null
                ? const Color(0xFFEF4444)
                : AppColors.border,
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedFile != null
                  ? Icons.picture_as_pdf_rounded
                  : Icons.upload_file_rounded,
              size: 52,
              color: _selectedFile != null
                  ? const Color(0xFFEF4444)
                  : AppColors.textMuted,
            ),
            const SizedBox(height: 14),
            Text(
              _selectedFile != null ? 'Archivo seleccionado' : 'Toca para seleccionar un PDF',
              style: TextStyle(
                color: _selectedFile != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Solo archivos .pdf',
              style: TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileInfo() {
    final kb = ((_selectedFile!.size ?? 0) / 1024).toStringAsFixed(1);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_rounded,
              color: Color(0xFFEF4444), size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_selectedFile!.name,
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
                Text('$kb KB',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
            onPressed: () => setState(() {
              _selectedFile = null;
              _uploadDone = false;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessBanner() => Container(
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'CV subido correctamente',
                style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

  Widget _buildUploadButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _selectedFile != null && !_isUploading && !_uploadDone
              ? _simularSubida
              : null,
          icon: _isUploading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : const Icon(Icons.cloud_upload_rounded),
          label: Text(_isUploading
              ? 'Subiendo...'
              : (_uploadDone ? 'Subido ✓' : 'Subir CV')),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      );
}
