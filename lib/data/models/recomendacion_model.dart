// lib/data/models/recomendacion_model.dart

/// Clase `Recomendacion` que modela una recomendación generada,
/// típicamente por un sistema de inteligencia artificial.
///
/// Este modelo está diseñado para reflejar la estructura de un DTO (Data Transfer Object)
/// llamado `RecomendacionDto` en el backend, el cual contiene un título y una descripción
/// para la recomendación. Es fundamental que las claves JSON para el título y la descripción
/// coincidan exactamente con las que el backend envía.
class Recomendacion {
  /// El título conciso de la recomendación.
  final String titulo;

  /// La descripción detallada o el contenido de la recomendación.
  final String descripcion;

  /// Constructor de la clase `Recomendacion`.
  ///
  /// Requiere que se proporcionen el `titulo` y la `descripcion` al crear una instancia.
  Recomendacion({
    required this.titulo,
    required this.descripcion,
  });

  /// Factory constructor `fromJson` para crear una instancia de `Recomendacion`
  /// a partir de un mapa JSON.
  ///
  /// Se utiliza cuando se reciben recomendaciones de una API.
  /// **Es crucial asegurarse de que las claves 'titulo' y 'descripcion'
  /// coincidan exactamente con las que tu backend envía en el JSON.**
  ///
  /// Si el backend utiliza C# con `System.Text.Json` (común en ASP.NET Core),
  /// por defecto, los nombres de propiedades en PascalCase (ej. `Titulo`, `Descripcion`)
  /// se convertirán a camelCase (es decir, `titulo`, `descripcion` con minúscula inicial)
  /// en el JSON de salida. Si experimentas problemas de deserialización,
  /// verifica los logs de depuración para ver el JSON exacto recibido.
  ///
  /// Se utiliza `as String` para realizar un casting explícito y asegurar el tipo de dato.
  factory Recomendacion.fromJson(Map<String, dynamic> json) {
    return Recomendacion(
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  /// Método `toJson` para convertir una instancia de `Recomendacion` a un mapa JSON.
  ///
  /// Este método es útil si en algún momento la aplicación Flutter necesitara
  /// enviar objetos `Recomendacion` de vuelta al backend (por ejemplo, para
  /// guardar una recomendación personalizada o retroalimentación).
  /// Convierte las propiedades `titulo` y `descripcion` en un mapa que puede ser
  /// serializado fácilmente a formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
    };
  }
}