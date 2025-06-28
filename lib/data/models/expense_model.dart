// expense_model.dart

/// La clase `Expense` representa un **gasto** registrado por un usuario en la aplicación.
///
/// Este modelo define la estructura de los datos para un gasto individual. Incluye
/// su identificador único, el ID del usuario que lo realizó, el ID del presupuesto
/// asociado (si lo hay), la categoría a la que pertenece, una descripción, el monto
/// del gasto y la fecha en que se incurrió.
class Expense {
  /// El **identificador único** del gasto.
  final int id;

  /// El **ID del usuario** que registró este gasto.
  final int usuarioId;

  /// El **ID del presupuesto** al que este gasto está vinculado.
  /// Puede ser `null` si el gasto no está asignado a un presupuesto específico.
  final int? presupuestoId;

  /// El **ID de la categoría** a la que pertenece este gasto (por ejemplo, "Alimentos", "Transporte").
  final int categoriaId;

  /// Una **descripción breve** del gasto.
  final String descripcion;

  /// El **monto monetario** del gasto.
  final double monto;

  /// La **fecha** en que se realizó el gasto.
  final DateTime fecha;

  /// Constructor de la clase `Expense`.
  ///
  /// Requiere que proporciones `id`, `usuarioId`, `categoriaId`,
  /// `descripcion`, `monto` y `fecha`. El `presupuestoId` es opcional
  /// y puede ser nulo.
  Expense({
    required this.id,
    required this.usuarioId,
    this.presupuestoId,
    required this.categoriaId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `Expense`
  /// a partir de un mapa JSON.
  ///
  /// Úsalo cuando recibas datos de gastos de tu API. Toma un `Map<String, dynamic>`
  /// (la representación JSON) y mapea sus claves a las propiedades de la clase `Expense`.
  /// Realiza la conversión de `monto` a `double` y parsea la cadena de `fecha`
  /// a un objeto `DateTime`.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'],
      usuarioId: json['usuarioId'],
      presupuestoId: json['presupuestoId'], // Será `null` si no está presente en el JSON.
      categoriaId: json['categoriaId'],
      descripcion: json['descripcion'],
      monto: (json['monto'] as num).toDouble(), // Convierte cualquier número a double.
      fecha: DateTime.parse(json['fecha']), // Parsea la cadena ISO 8601 a DateTime.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `Expense` a un mapa JSON.
  ///
  /// Este método se utiliza para serializar el objeto `Expense` y enviarlo
  /// a un backend (por ejemplo, para crear o actualizar un gasto).
  /// La fecha se convierte a una cadena en formato `ISO 8601` completa para
  /// asegurar la compatibilidad con el backend.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'presupuestoId': presupuestoId,
      'categoriaId': categoriaId,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha.toIso8601String(), // Convierte DateTime a cadena ISO 8601 para JSON.
    };
  }
}