import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/pdf_cv_service.dart';

/// Página para cargar el CV deportivo en formato PDF.
class PdfUploadPage extends StatefulWidget {
  const PdfUploadPage({super.key});

  @override
  State<PdfUploadPage> createState() => _PdfUploadPageState();
}

class _PdfUploadPageState extends State<PdfUploadPage> {
  String?  _fileName;
  int?     _fileSize;
  Uint8List? _fileBytes;

  bool   _isUploading = false;
  bool   _uploadDone  = false;
  String? _errorMsg;

  // CV guardado previamente en el servidor
  bool    _isLoadingInfo     = true;
  String? _cvExistenteNombre;  // nombre del CV ya subido
  bool    _isDeleting        = false;
  @override
  void initState() {
    super.initState();
    _cargarInfoCv();
  }

  // ── Info del CV existente en servidor ─────────────────────────────────

  Future<void> _cargarInfoCv() async {
    setState(() => _isLoadingInfo = true);
    final res = await PdfCvService.obtenerInfoCv();
    if (!mounted) return;
    setState(() {
      _isLoadingInfo = false;
      _cvExistenteNombre = res.cvNombre;
    });
  }

  Future<void> _confirmarEliminarCv() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar CV',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
            '¿Estás seguro de que quieres eliminar tu CV? Esta acción no se puede deshacer.',
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
    if (ok != true || !mounted) return;

    setState(() => _isDeleting = true);
    final res = await PdfCvService.eliminarCv();
    if (!mounted) return;
    setState(() {
      _isDeleting = false;
      if (res.success) {
        _cvExistenteNombre = null;
        _uploadDone = false;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res.message ?? 'Error'),
      backgroundColor: res.success ? AppColors.success : AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ));
  }
  // ── Selección de archivo ──────────────────────────────────────────────────

  Future<void> _pickPdf() async {
    setState(() { _errorMsg = null; _uploadDone = false; });

    FilePickerResult? result;
    try {
      result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
        withData: true,          // ← imprescindible: carga los bytes en web y mobile
        withReadStream: false,
      );
    } catch (e) {
      setState(() => _errorMsg = 'No se pudo abrir el selector de archivos.');
      return;
    }

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;

    if (file.bytes == null) {
      setState(() => _errorMsg = 'No se pudieron leer los datos del archivo.');
      return;
    }

    setState(() {
      _fileName  = file.name;
      _fileSize  = file.size;
      _fileBytes = file.bytes;
    });
  }

  // ── Subida real ──────────────────────────────────────────────────────────

  Future<void> _subirCv() async {
    if (_fileBytes == null || _fileName == null) return;
    setState(() { _isUploading = true; _errorMsg = null; _uploadDone = false; });

    final res = await PdfCvService.subirCv(
      bytes: _fileBytes!,
      filename: _fileName!,
    );

    if (!mounted) return;
    if (res.success) {
      setState(() {
        _isUploading = false;
        _uploadDone = true;
        _cvExistenteNombre = _fileName; // actualiza el nombre del CV en el servidor
      });
    } else {
      setState(() { _isUploading = false; _errorMsg = res.message; });
    }
  }

  void _resetFile() => setState(() {
        _fileName   = null;
        _fileSize   = null;
        _fileBytes  = null;
        _uploadDone = false;
        _errorMsg   = null;
      });

  // ── UI ───────────────────────────────────────────────────────────────────

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
      body: SafeArea(
        child: _isLoadingInfo
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFEF4444)))
            : Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Banner: CV ya guardado en el servidor
              if (_cvExistenteNombre != null && !_uploadDone)
                _ExistingCvBanner(
                  nombre: _cvExistenteNombre!,
                  isDeleting: _isDeleting,
                  onDelete: _confirmarEliminarCv,
                ),
              if (_cvExistenteNombre != null && !_uploadDone)
                const SizedBox(height: 16),
              _DropZone(
                hasFile: _fileBytes != null,
                uploadDone: _uploadDone,
                onTap: _uploadDone ? null : _pickPdf,
              ),
              const SizedBox(height: 20),
              if (_fileBytes != null && !_uploadDone)
                _FileInfoCard(
                  name: _fileName!,
                  sizeBytes: _fileSize ?? _fileBytes!.length,
                  onRemove: _resetFile,
                ),
              if (_uploadDone) _SuccessBanner(fileName: _fileName!),
              if (_errorMsg != null) _ErrorBanner(message: _errorMsg!),
              const Spacer(),
              _UploadButton(
                enabled: _fileBytes != null && !_isUploading && !_uploadDone,
                isLoading: _isUploading,
                isDone: _uploadDone,
                onPressed: _subirCv,
              ),
              if (_uploadDone) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text('Subir otro CV'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _resetFile,
                  ),
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _DropZone extends StatelessWidget {
  final bool hasFile;
  final bool uploadDone;
  final VoidCallback? onTap;

  const _DropZone({
    required this.hasFile,
    required this.uploadDone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = uploadDone
        ? AppColors.success
        : hasFile
            ? const Color(0xFFEF4444)
            : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 195,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.55), width: 1.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBubble(icon: _icon, color: color),
            const SizedBox(height: 14),
            Text(
              _label,
              style: TextStyle(
                  color: hasFile ? AppColors.textPrimary : AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              uploadDone ? '' : 'Solo archivos .pdf',
              style:
                  const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    if (uploadDone) return Icons.check_circle_outline_rounded;
    if (hasFile) return Icons.picture_as_pdf_rounded;
    return Icons.upload_file_rounded;
  }

  String get _label {
    if (uploadDone) return 'CV subido correctamente';
    if (hasFile) return 'Archivo listo para subir';
    return 'Toca para seleccionar un PDF';
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _IconBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.04),
          ]),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Icon(icon, color: color, size: 34),
      );
}

class _FileInfoCard extends StatelessWidget {
  final String name;
  final int sizeBytes;
  final VoidCallback onRemove;

  const _FileInfoCard({
    required this.name,
    required this.sizeBytes,
    required this.onRemove,
  });

  String get _sizeLabel {
    if (sizeBytes >= 1024 * 1024) {
      return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFEF4444), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(_sizeLabel,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded,
                  color: AppColors.textMuted, size: 20),
              onPressed: onRemove,
            ),
          ],
        ),
      );
}

class _SuccessBanner extends StatelessWidget {
  final String fileName;
  const _SuccessBanner({required this.fileName});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¡CV subido correctamente!',
                      style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(fileName,
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 13)),
            ),
          ],
        ),
      );
}

// Banner que muestra el CV actualmente guardado en el servidor
class _ExistingCvBanner extends StatelessWidget {
  final String nombre;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _ExistingCvBanner({
    required this.nombre,
    required this.isDeleting,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFFFFD700), size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CV guardado en el servidor',
                      style: TextStyle(
                          color: Color(0xFFFFD700),
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(nombre,
                      style: const TextStyle(
                          color: AppColors.textPrimary, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFEF4444)))
                : IconButton(
                    tooltip: 'Eliminar CV',
                    icon: const Icon(Icons.delete_outline_rounded,
                        color: Color(0xFFEF4444), size: 22),
                    onPressed: onDelete,
                  ),
          ],
        ),
      );
}

class _UploadButton extends StatelessWidget {
  final bool enabled;
  final bool isLoading;
  final bool isDone;
  final VoidCallback onPressed;

  const _UploadButton({
    required this.enabled,
    required this.isLoading,
    required this.isDone,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: enabled ? onPressed : null,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5))
              : Icon(isDone
                  ? Icons.check_rounded
                  : Icons.cloud_upload_rounded),
          label: Text(isLoading
              ? 'Subiendo...'
              : isDone
                  ? 'Subido ✓'
                  : 'Subir CV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                const Color(0xFFEF4444).withValues(alpha: 0.35),
            disabledForegroundColor: Colors.white54,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
      );
}


