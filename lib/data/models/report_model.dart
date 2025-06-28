// report_model.dart

/// La clase `Report` modela un **reporte generado** dentro de la aplicación.
///
/// Este modelo representa un documento que ha sido creado, usualmente por el backend,
/// y que el usuario puede descargar o visualizar. Incluye información crucial
/// como su identificador, el usuario que lo originó, su nombre, el tipo de archivo,
/// la ubicación para accederlo y la fecha de su creación.
class Report {
  /// El **identificador único** del reporte.
  final int id;

  /// El **ID del usuario** que generó este reporte.
  final int usuarioId;

  /// El **nombre** del reporte (ej. "Reporte Mensual de Gastos").
  final String nombre;

  /// El **tipo** de reporte (ej. "PDF", "CSV", "Anual", "Mensual").
  final String tipo;

  /// La **ruta o URL** donde se puede acceder al archivo del reporte.
  final String rutaArchivo;

  /// La **fecha y hora** en que se generó el reporte.
  final DateTime fechaGeneracion;

  /// Constructor de la clase `Report`.
  ///
  /// Requiere que se proporcionen todos los campos (`id`, `usuarioId`, `nombre`,
  /// `tipo`, `rutaArchivo`, `fechaGeneracion`) al crear una instancia de `Report`.
  Report({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tipo,
    required this.rutaArchivo,
    required this.fechaGeneracion,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `Report`
  /// a partir de un mapa JSON.
  ///
  /// Se utiliza al deserializar datos de reportes recibidos desde una API.
  /// Toma un `Map<String, dynamic>` y mapea sus claves a las propiedades correspondientes
  /// de la clase `Report`. La cadena `fechaGeneracion` se convierte a un objeto `DateTime`.
  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      usuarioId: json['usuarioId'],
      nombre: json['nombre'],
      tipo: json['tipo'],
      rutaArchivo: json['rutaArchivo'],
      fechaGeneracion: DateTime.parse(json['fechaGeneracion']), // Convierte la cadena de fecha a DateTime.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `Report` a un mapa JSON.
  ///
  /// Este método es útil para serializar un objeto `Report` a un formato JSON,
  /// por ejemplo, si la aplicación Flutter necesitara enviar información sobre
  /// un reporte a un backend o guardarlo localmente. La fecha se serializa
  /// a una cadena en formato `ISO 8601` completo.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nombre': nombre,
      'tipo': tipo,
      'rutaArchivo': rutaArchivo,
      'fechaGeneracion': fechaGeneracion.toIso8601String(), // Convierte DateTime a cadena ISO 8601 para JSON.
    };
  }
}