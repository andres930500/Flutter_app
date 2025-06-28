/// La clase `CategoryTotal` representa un resumen del monto total (ya sea de ingresos o gastos)
/// asociado a una categoría específica.
///
/// Este modelo es muy útil para **visualizar datos financieros agregados**,
/// por ejemplo, para mostrar cuánto se ha gastado en "Alimentos" o cuánto se ha ingresado por "Salario"
/// en un período determinado.
class CategoryTotal {
  /// El **nombre de la categoría** a la que corresponde el monto total.
  final String categoria;

  /// El **monto total** acumulado para esa categoría.
  final double monto;

  /// Constructor de la clase `CategoryTotal`.
  ///
  /// Requiere que proporciones el `categoria` (nombre) y el `monto` total
  /// al crear una instancia de esta clase.
  CategoryTotal({required this.categoria, required this.monto});

  /// **Constructor `factory` `fromJson`** para crear una instancia de `CategoryTotal`
  /// a partir de un mapa JSON.
  ///
  /// Se usa cuando recibes datos agregados de tu API. Asume que el JSON de entrada tendrá:
  /// - Una clave `'categoria'` para el nombre de la categoría.
  /// - Una clave `'total'` para el monto agregado. Es importante notar que tu backend
  ///   podría usar 'total' en lugar de 'monto' para el valor numérico en este tipo de agregaciones.
  ///   El valor se convierte a `double` y se usa `0.0` como valor por defecto si es nulo.
  factory CategoryTotal.fromJson(Map<String, dynamic> json) {
    return CategoryTotal(
      categoria: json['categoria'],
      monto: (json['total'] as num).toDouble(), // Convierte el valor de 'total' a double.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `CategoryTotal` a un mapa JSON.
  ///
  /// Este método es útil si necesitas serializar este objeto para enviarlo a un backend
  /// o para almacenamiento local. Convierte las propiedades del objeto en un
  /// `Map<String, dynamic>` con las claves `'categoria'` y `'total'`.
  Map<String, dynamic> toJson() {
    return {
      'categoria': categoria,
      'total': monto, // Aquí mantenemos la clave 'total' para la serialización.
    };
  }
}