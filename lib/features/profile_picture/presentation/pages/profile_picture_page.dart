import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../application/profile_picture_service.dart';
import '../widgets/profile_avatar_widget.dart';

/// Página para gestionar la foto de perfil del usuario.
/// Permite seleccionar desde galería o cámara, previsualizar, subir y eliminar.
class ProfilePicturePage extends StatefulWidget {
  /// Nombre del usuario (para las iniciales del avatar).
  final String nombre;

  /// Bytes de la foto actual (null si no tiene foto).
  final Uint8List? fotoActual;

  const ProfilePicturePage({
    super.key,
    required this.nombre,
    this.fotoActual,
  });

  @override
  State<ProfilePicturePage> createState() => _ProfilePicturePageState();
}

class _ProfilePicturePageState extends State<ProfilePicturePage> {
  final _picker = ImagePicker();

  Uint8List? _preview;   // foto seleccionada localmente (no subida aún)
  Uint8List? _guardada;  // foto actualmente guardada en el servidor

  bool _isSaving   = false;
  bool _isDeleting = false;
  bool _isLoading  = true;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _guardada = widget.fotoActual;
    _cargarFoto();
  }

  // ── Carga desde servidor ────────────────────────────────────────────────

  Future<void> _cargarFoto() async {
    setState(() => _isLoading = true);
    final result = await ProfilePictureService.obtenerFoto();
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (result.success) {
        _guardada = result.entity?.imageBytes;
      }
    });
  }

  // ── Seleccionar imagen ──────────────────────────────────────────────────

  Future<void> _seleccionarImagen(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      setState(() { _preview = bytes; _errorMsg = null; });
    } catch (_) {
      setState(() => _errorMsg = 'No se pudo acceder a la imagen.');
    }
  }

  void _mostrarOpciones() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _OptionsSheet(
        tienePreview: _preview != null,
        tieneGuardada: _guardada != null,
        onGaleria: () {
          Navigator.pop(context);
          _seleccionarImagen(ImageSource.gallery);
        },
        onCamara: () {
          Navigator.pop(context);
          _seleccionarImagen(ImageSource.camera);
        },
        onDescartar: _preview != null
            ? () {
                Navigator.pop(context);
                setState(() => _preview = null);
              }
            : null,
      ),
    );
  }

  // ── Guardar en MongoDB ──────────────────────────────────────────────────

  Future<void> _guardarFoto() async {
    if (_preview == null) return;
    setState(() { _isSaving = true; _errorMsg = null; });

    final result = await ProfilePictureService.guardarFoto(_preview!);
    if (!mounted) return;

    if (result.success) {
      setState(() {
        _isSaving  = false;
        _guardada  = _preview!;
        _preview   = null;
      });
      _snack('Foto de perfil guardada', ok: true);
      // Devuelve los bytes al llamador para actualizar el avatar inmediatamente
      Navigator.pop(context, _guardada);
    } else {
      setState(() { _isSaving = false; _errorMsg = result.message; });
    }
  }

  // ── Eliminar de MongoDB ─────────────────────────────────────────────────

  Future<void> _confirmarEliminar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar foto',
            style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          '¿Seguro que quieres eliminar tu foto de perfil?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar',
                  style: TextStyle(color: AppColors.textMuted))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar',
                  style: TextStyle(color: AppColors.danger))),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() { _isDeleting = true; _errorMsg = null; });
    final result = await ProfilePictureService.eliminarFoto();
    if (!mounted) return;

    if (result.success) {
      setState(() { _isDeleting = false; _guardada = null; _preview = null; });
      _snack('Foto eliminada', ok: true);
      Navigator.pop(context, null); // null indica que se borró
    } else {
      setState(() { _isDeleting = false; _errorMsg = result.message; });
    }
  }

  void _snack(String msg, {required bool ok}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: ok ? AppColors.success : AppColors.danger,
      behavior: SnackBarBehavior.floating,
    ));
  }

  // ── UI ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // La imagen que se muestra: preview local > guardada > null (iniciales)
    final displayBytes = _preview ?? _guardada;
    final busy = _isSaving || _isDeleting;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Foto de perfil'),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          if (_guardada != null && !busy)
            IconButton(
              tooltip: 'Eliminar foto',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.danger),
              onPressed: _confirmarEliminar,
            ),
          if (busy)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2.5, color: AppColors.primary),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // ── Avatar grande ────────────────────────────────────
                    ProfileAvatarWidget(
                      nombre: widget.nombre,
                      imageBytes: displayBytes,
                      radius: 80,
                      showEditBadge: true,
                      onTap: busy ? null : _mostrarOpciones,
                    ),

                    const SizedBox(height: 20),

                    // Indicador de estado
                    Text(
                      _preview != null
                          ? 'Imagen seleccionada — toca "Guardar" para subir'
                          : _guardada != null
                              ? 'Foto de perfil activa'
                              : 'Sin foto de perfil',
                      style: TextStyle(
                        color: _preview != null
                            ? AppColors.warning
                            : _guardada != null
                                ? AppColors.success
                                : AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    if (_errorMsg != null) ...[
                      const SizedBox(height: 12),
                      _ErrorBanner(message: _errorMsg!),
                    ],

                    const Spacer(),

                    // ── Botones ──────────────────────────────────────────
                    if (_preview != null)
                      _ActionButton(
                        label: 'Guardar foto',
                        icon: Icons.cloud_upload_rounded,
                        color: AppColors.primary,
                        isLoading: _isSaving,
                        onPressed: busy ? null : _guardarFoto,
                      ),
                    const SizedBox(height: 12),
                    _ActionButton(
                      label: _preview != null
                          ? 'Cambiar selección'
                          : 'Seleccionar foto',
                      icon: Icons.photo_library_rounded,
                      color: AppColors.surface,
                      foreground: AppColors.primary,
                      outlined: true,
                      onPressed: busy ? null : _mostrarOpciones,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

// ── Subwidgets ────────────────────────────────────────────────────────────────

class _OptionsSheet extends StatelessWidget {
  final bool tienePreview;
  final bool tieneGuardada;
  final VoidCallback onGaleria;
  final VoidCallback onCamara;
  final VoidCallback? onDescartar;

  const _OptionsSheet({
    required this.tienePreview,
    required this.tieneGuardada,
    required this.onGaleria,
    required this.onCamara,
    this.onDescartar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Cambiar foto',
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          _SheetTile(
            icon: Icons.photo_library_rounded,
            color: AppColors.primary,
            label: 'Galería',
            subtitle: 'Seleccionar desde tus fotos',
            onTap: onGaleria,
          ),
          _SheetTile(
            icon: Icons.camera_alt_rounded,
            color: const Color(0xFF8B5CF6),
            label: 'Cámara',
            subtitle: 'Tomar una foto ahora',
            onTap: onCamara,
          ),
          if (onDescartar != null)
            _SheetTile(
              icon: Icons.undo_rounded,
              color: AppColors.warning,
              label: 'Descartar selección',
              subtitle: 'Volver a la foto guardada',
              onTap: onDescartar!,
            ),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(label,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 12)),
        onTap: onTap,
      );
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? foreground;
  final bool outlined;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.foreground,
    this.outlined = false,
    this.isLoading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
                color: Colors.white, strokeWidth: 2.5),
          )
        else
          Icon(icon, size: 18),
        const SizedBox(width: 8),
        Text(label),
      ],
    );

    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14));
    const padding = EdgeInsets.symmetric(vertical: 15);
    const textStyle = TextStyle(fontSize: 15, fontWeight: FontWeight.w700);

    if (outlined) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: foreground ?? color,
            side: BorderSide(color: foreground ?? color),
            padding: padding,
            shape: shape,
            textStyle: textStyle,
          ),
          child: content,
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: foreground ?? Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.35),
          padding: padding,
          shape: shape,
          textStyle: textStyle,
          elevation: 0,
        ),
        child: content,
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: AppColors.danger, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(message,
                  style: const TextStyle(
                      color: AppColors.danger, fontSize: 13)),
            ),
          ],
        ),
      );
}
