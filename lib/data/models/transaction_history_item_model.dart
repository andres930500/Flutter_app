// lib/data/models/transaction_history_item_model.dart

import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo para Gastos.
import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo para Ingresos.

/// La clase `TransactionHistoryItem` sirve como una **abstracción unificada**
/// para representar tanto **Ingresos** como **Gastos** en una sola lista.
///
/// Esto es ideal para mostrar un historial combinado de transacciones,
/// donde la principal diferencia es si el monto suma o resta al balance general.
class TransactionHistoryItem {
  /// El **identificador único** de la transacción (ya sea un ingreso o un gasto).
  final int id;

  /// El **ID del usuario** al que pertenece esta transacción.
  final int usuarioId;

  /// El **ID del presupuesto** al que la transacción está vinculada, si aplica.
  /// Puede ser `null` si no está asociada a ningún presupuesto.
  final int? presupuestoId;

  /// El **ID de la categoría** de la transacción.
  /// Puede ser `null` para ciertos tipos de ingresos según tu esquema actual,
  /// pero usualmente no para los gastos.
  final int? categoriaId;

  /// Una **descripción breve** de la transacción.
  final String descripcion;

  /// El **monto monetario** de la transacción.
  final double monto;

  /// La **fecha** en que se realizó la transacción.
  final DateTime fecha;

  /// Un indicador booleano: es `true` si la transacción es un **gasto**,
  /// y `false` si es un **ingreso**. Esto es clave para diferenciar
  /// visualmente y lógicamente los tipos de transacciones en tu interfaz de usuario.
  final bool isExpense;

  /// Constructor principal de la clase `TransactionHistoryItem`.
  ///
  /// Requiere todos los campos fundamentales para definir una transacción.
  TransactionHistoryItem({
    required this.id,
    required this.usuarioId,
    this.presupuestoId,
    this.categoriaId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    required this.isExpense,
  });

  

/// Constructores `factory` para Conversión

  ///Estos constructores `factory` te permiten crear instancias de `TransactionHistoryItem`
  ///directamente desde los modelos específicos de `Expense` o `Income`,
  ///lo que facilita la unificación de datos para tu historial.

  

  /// Constructor `factory` para crear un `TransactionHistoryItem` a partir de un objeto **`Expense`**.
  ///
  /// Mapea las propiedades de un `Expense` a las de `TransactionHistoryItem`,
  /// estableciendo automáticamente `isExpense` en `true`.
  factory TransactionHistoryItem.fromExpense(Expense expense) {
    return TransactionHistoryItem(
      id: expense.id,
      usuarioId: expense.usuarioId,
      presupuestoId: expense.presupuestoId,
      categoriaId: expense.categoriaId,
      descripcion: expense.descripcion,
      monto: expense.monto,
      fecha: expense.fecha,
      isExpense: true, // Indica que es un gasto.
    );
  }

  /// Constructor `factory` para crear un `TransactionHistoryItem` a partir de un objeto **`Income`**.
  ///
  /// Mapea las propiedades de un `Income` a las de `TransactionHistoryItem`,
  /// estableciendo automáticamente `isExpense` en `false`.
  factory TransactionHistoryItem.fromIncome(Income income) {
    return TransactionHistoryItem(
      id: income.id,
      usuarioId: income.usuarioId,
      presupuestoId: income.presupuestoId,
      categoriaId: income.categoriaId, // Nota: `categoriaId` es nullable en el modelo `Income`.
      descripcion: income.descripcion,
      monto: income.monto,
      fecha: income.fecha,
      isExpense: false, // Indica que es un ingreso.
    );
  }

  /// Constructor `factory` `fromJson` para crear un `TransactionHistoryItem`
  /// directamente desde un mapa JSON.
  ///
  /// Este constructor sería útil si tu API del backend ya te devolviera un objeto
  /// que combinara las propiedades de ingresos y gastos, incluyendo un indicador
  /// como `isExpense`. Esto es menos común que tener endpoints separados para
  /// ingresos y gastos, pero proporciona flexibilidad.
  ///
  /// Asume que el JSON de entrada contendrá todas las claves necesarias,
  /// incluyendo `'isExpense'` como un booleano.
  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryItem(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int,
      presupuestoId: json['presupuestoId'] as int?,
      categoriaId: json['categoriaId'] as int?,
      descripcion: json['descripcion'] as String,
      monto: (json['monto'] as num).toDouble(), // Convierte cualquier número a double.
      fecha: DateTime.parse(json['fecha'] as String), // Parsea la cadena ISO 8601 a DateTime.
      isExpense: json['isExpense'] as bool, // Espera un flag booleano de la API.
    );
  }
}