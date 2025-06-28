// category_model.dart

/// Clase `Category` que representa una **categoría** de ingresos o gastos en tu aplicación.
///
/// Este modelo se alinea con la estructura de datos que esperarías de una entidad 'Categorium'
/// en un backend (como el que podrías definir en C#).
/// Define las propiedades esenciales de una categoría: su **identificador único**,
/// el **nombre** y el **tipo** (ej. "Ingreso" o "Gasto").
class Category {
  /// El identificador único de la categoría.
  final int id;

  /// El nombre descriptivo de la categoría (ej. "Alimentos", "Transporte", "Salario").
  final String nombre;

  /// El tipo de categoría, que puede ser "Ingreso" o "Gasto".
  final String tipo;

  /// Constructor de la clase `Category`.
  ///
  /// Requiere que proporciones el `id`, `nombre` y `tipo` al crear una instancia de `Category`.
  Category({
    required this.id,
    required this.nombre,
    required this.tipo,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `Category` desde un mapa JSON.
  ///
  /// Utilízalo cuando recibas datos de tu API. Toma un `Map<String, dynamic>` (que es la representación
  /// JSON de una categoría) y extrae los valores para inicializar las propiedades de la clase `Category`.
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      nombre: json['nombre'],
      tipo: json['tipo'],
    );
  }

  /// **Método `toJson`** para convertir una instancia de `Category` a un mapa JSON.
  ///
  /// Este método es útil cuando necesitas enviar una instancia de `Category` a tu API
  /// (por ejemplo, para crear o actualizar una categoría). Convierte las propiedades
  /// del objeto `Category` en un `Map<String, dynamic>` que puede ser fácilmente
  /// serializado a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'tipo': tipo,
    };
  }
}
