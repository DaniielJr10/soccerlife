import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../services/api_config.dart';
import '../../../services/storage_service.dart';
import '../domain/entities/fifa_card_entity.dart';

/// Resultado genérico de las operaciones de Carta FIFA.
class FifaCardResult {
  final bool success;
  final String? message;
  final FifaCardEntity? carta;
  const FifaCardResult({required this.success, this.message, this.carta});
}

/// Servicio CRUD para la Carta FIFA — sincroniza con MongoDB.
class FifaCardService {
  static final _base = '${ApiConfig.baseUrl}/usuarios/carta-fifa';

  // ── helper de cabecera ───────────────────────────────────────────────────

  static Future<Map<String, String>?> _headers() async {
    final token = await StorageService.obtenerToken();
    if (token == null) return null;
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ── Obtener carta ────────────────────────────────────────────────────────

  /// Carga la carta FIFA del usuario desde MongoDB.
  /// Devuelve `carta: null` si el usuario todavía no tiene carta.
  static Future<FifaCardResult> obtenerCarta() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const FifaCardResult(
            success: false, message: 'No autenticado.');
      }

      final res = await http
          .get(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final rawCarta = body['cartaFifa'];
        if (rawCarta == null) {
          return const FifaCardResult(success: true, carta: null);
        }
        final carta = _fromJson(rawCarta as Map<String, dynamic>);
        return FifaCardResult(success: true, carta: carta);
      } else {
        return FifaCardResult(
            success: false,
            message: 'Error (${res.statusCode})');
      }
    } on Exception catch (e) {
      return FifaCardResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Guardar carta ────────────────────────────────────────────────────────

  /// Crea o reemplaza la carta FIFA del usuario en MongoDB.
  static Future<FifaCardResult> guardarCarta(FifaCardEntity carta) async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const FifaCardResult(
            success: false, message: 'No autenticado.');
      }

      final body = _toJson(carta);
      final res = await http
          .put(Uri.parse(_base),
              headers: headers, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200 || res.statusCode == 201) {
        return const FifaCardResult(
            success: true, message: 'Carta guardada correctamente.');
      } else {
        final msg = _extractMessage(res.body);
        return FifaCardResult(success: false, message: msg);
      }
    } on Exception catch (e) {
      return FifaCardResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Eliminar carta ───────────────────────────────────────────────────────

  /// Elimina la carta FIFA del usuario de MongoDB.
  static Future<FifaCardResult> eliminarCarta() async {
    try {
      final headers = await _headers();
      if (headers == null) {
        return const FifaCardResult(
            success: false, message: 'No autenticado.');
      }

      final res = await http
          .delete(Uri.parse(_base), headers: headers)
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        return const FifaCardResult(
            success: true, message: 'Carta FIFA eliminada.');
      } else {
        return FifaCardResult(
            success: false, message: 'Error (${res.statusCode})');
      }
    } on Exception catch (e) {
      return FifaCardResult(
          success: false,
          message: e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ── Conversión entidad ↔ JSON ────────────────────────────────────────────

  static Map<String, dynamic> _toJson(FifaCardEntity c) => {
        'nombre': c.nombre,
        'posicion': c.posicion,
        'overall': c.overall,
        'ritmo': c.ritmo,
        'tiro': c.tiro,
        'pase': c.pase,
        'regate': c.regate,
        'defensa': c.defensa,
        'fisico': c.fisico,
        'contacto': c.contacto,
        'club': c.club,
        'nacionalidad': c.nacionalidad,
        // La imagen se codifica en base64 para almacenarla como texto
        'imagenBase64': c.imageBytes != null
            ? base64Encode(c.imageBytes!)
            : null,
      };

  static FifaCardEntity _fromJson(Map<String, dynamic> j) {
    Uint8List? bytes;
    if (j['imagenBase64'] != null &&
        (j['imagenBase64'] as String).isNotEmpty) {
      bytes = base64Decode(j['imagenBase64'] as String);
    }
    return FifaCardEntity(
      nombre:      (j['nombre']      as String?) ?? '',
      posicion:    (j['posicion']    as String?) ?? 'Delantero',
      overall:     (j['overall']     as num?)?.toInt() ?? 75,
      ritmo:       (j['ritmo']       as num?)?.toInt() ?? 75,
      tiro:        (j['tiro']        as num?)?.toInt() ?? 75,
      pase:        (j['pase']        as num?)?.toInt() ?? 75,
      regate:      (j['regate']      as num?)?.toInt() ?? 75,
      defensa:     (j['defensa']     as num?)?.toInt() ?? 75,
      fisico:      (j['fisico']      as num?)?.toInt() ?? 75,
      contacto:    (j['contacto']    as String?) ?? '',
      club:        (j['club']        as String?) ?? '',
      nacionalidad:(j['nacionalidad']as String?) ?? '',
      imageBytes:  bytes,
    );
  }

  static String _extractMessage(String body) {
    try {
      final decoded = jsonDecode(body) as Map<String, dynamic>;
      return (decoded['message'] as String?) ?? 'Error desconocido';
    } catch (_) {
      return 'Error desconocido';
    }
  }
}
