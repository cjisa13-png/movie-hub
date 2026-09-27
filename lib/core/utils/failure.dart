/// Representa un error controlado dentro de la app.
/// En lugar de lanzar excepciones "crudas", envolvemos los errores en
/// objetos [Failure] con un mensaje legible para mostrar al usuario.
class Failure implements Exception {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Error de red (sin conexión, timeout, servidor caído...).
class NetworkFailure extends Failure {
  const NetworkFailure(
      [super.message = 'Sin conexión a internet. Revisa tu red.']);
}

/// Error del servidor / respuesta HTTP no válida.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor de TMDB.']);
}

/// La clave de API no está configurada o es inválida.
class ApiKeyFailure extends Failure {
  const ApiKeyFailure([
    super.message =
        'Falta configurar tu clave de API de TMDB. Revisa el archivo '
        'lib/core/constants/api_constants.dart.',
  ]);
}
