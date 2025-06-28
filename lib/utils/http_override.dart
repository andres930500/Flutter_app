import 'dart:io'; // Importa la librería 'dart:io' que proporciona clases para interactuar con el sistema operativo, incluyendo operaciones de red.

/// **`MyHttpOverrides`** es una clase que extiende `HttpOverrides`.
/// Su propósito principal es **permitir que la aplicación Flutter confíe en certificados
/// SSL/TLS auto-firmados o inválidos** durante el desarrollo.
///
/// Esto es comúnmente necesario cuando se trabaja con servidores de desarrollo
/// que utilizan certificados HTTPS no emitidos por una autoridad de certificación (CA)
/// reconocida, o cuando se usa HTTP en lugar de HTTPS con configuraciones de seguridad
/// que lo requieren.
///
/// **¡Advertencia!**: Configurar `badCertificateCallback` para que siempre retorne `true`
/// (`(cert, host, port) => true`) **deshabilita por completo la validación de certificados SSL/TLS**.
/// Esto **NO DEBE UTILIZARSE EN ENTORNOS DE PRODUCCIÓN** ya que expone la aplicación
/// a vulnerabilidades de seguridad significativas, como ataques "Man-in-the-Middle".
/// Su uso está restringido a entornos de desarrollo y depuración.
class MyHttpOverrides extends HttpOverrides {
  /// **Sobreescribe el método `createHttpClient`** del padre `HttpOverrides`.
  ///
  /// Este método es invocado por Flutter cuando necesita crear una instancia de
  /// `HttpClient` para realizar peticiones HTTP/HTTPS.
  ///
  /// * `context`: Un `SecurityContext` opcional que podría contener certificados
  ///   confiables adicionales o configuraciones de seguridad.
  ///
  /// Retorna una instancia de `HttpClient` configurada para ignorar errores de certificado.
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    // Llama al método `createHttpClient` de la clase padre (`super`) para obtener
    // la implementación por defecto de `HttpClient`.
    return super.createHttpClient(context)
        // Se utiliza el operador `..` (cascade operator) para encadenar llamadas
        // al mismo objeto `HttpClient` devuelto por `super.createHttpClient`.
        ..badCertificateCallback = (X509Certificate cert, String host, int port) =>
            true; // Configura el callback que se ejecuta cuando el certificado SSL/TLS del servidor
                  // no es válido o no es de confianza. Al retornar `true`, se indica a Flutter
                  // que acepte (confíe en) *cualquier* certificado, sin importar su validez.
  }
}