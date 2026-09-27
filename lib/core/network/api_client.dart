import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_key_store.dart';
import '../constants/api_constants.dart';
import '../utils/failure.dart';

/// Cliente HTTP genérico para hablar con la API de TMDB.
///
/// Se encarga de:
///   - Añadir automáticamente la `api_key` y el `language` a cada petición.
///   - Gestionar timeouts y errores de red.
///   - Convertir la respuesta en JSON (Map) o lanzar un [Failure] claro.
///
/// Todas las clases de datos (datasources) usan este cliente en lugar de
/// llamar a `http` directamente, para no repetir la lógica de errores.
class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  /// Realiza una petición GET al [endpoint] indicado.
  /// [queryParams] son parámetros extra (filtros, página, etc.).
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    // Comprobación temprana: si el usuario no puso su clave, avisamos claro.
    if (ApiKeyStore.isMissing) {
      throw const ApiKeyFailure();
    }

    // Parámetros base que van en TODAS las peticiones.
    final params = <String, String>{
      'api_key': ApiKeyStore.effectiveKey,
      'language': ApiConstants.language,
      ...?queryParams,
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint')
        .replace(queryParameters: params);

    try {
      final response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on TimeoutException {
      throw const NetworkFailure('La conexión tardó demasiado. Inténtalo de nuevo.');
    } on http.ClientException {
      throw const NetworkFailure();
    } on FormatException {
      throw const ServerFailure('La respuesta de TMDB no tiene un formato válido.');
    }
  }

  /// Interpreta el código de estado HTTP y devuelve el JSON o lanza un error.
  Map<String, dynamic> _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return json.decode(response.body) as Map<String, dynamic>;
      case 401:
        throw const ApiKeyFailure(
            'Tu clave de API de TMDB no es válida (error 401).');
      case 404:
        throw const ServerFailure('No se encontró el recurso solicitado (404).');
      case 429:
        throw const ServerFailure(
            'Demasiadas peticiones. Espera unos segundos e inténtalo otra vez.');
      default:
        throw ServerFailure(
            'Error inesperado de TMDB (código ${response.statusCode}).');
    }
  }

  void dispose() => _client.close();
}
