/// La clase `DashboardSummary` modela un resumen de los datos financieros clave
/// que se muestran en el dashboard de tu aplicación.
///
/// Este modelo está diseñado para encapsular valores agregados como el balance actual,
/// los ingresos totales del mes y los gastos totales del mes, proporcionando
/// una vista rápida y concisa de la situación financiera del usuario.
class DashboardSummary {
  /// El **balance actual** de las finanzas del usuario.
  final double currentBalance;

  /// El **monto total de ingresos** registrados durante el mes actual.
  final double totalIncomeThisMonth;

  /// El **monto total de gastos** registrados durante el mes actual.
  final double totalExpensesThisMonth;

  /// Constructor de la clase `DashboardSummary`.
  ///
  /// Requiere que proporciones el `currentBalance`, `totalIncomeThisMonth`
  /// y `totalExpensesThisMonth` al crear una instancia.
  DashboardSummary({
    required this.currentBalance,
    required this.totalIncomeThisMonth,
    required this.totalExpensesThisMonth,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `DashboardSummary`
  /// a partir de un mapa JSON.
  ///
  /// Utilízalo cuando recibas datos agregados de tu API para el dashboard.
  /// Convierte los valores numéricos (que pueden venir como `int` o `double` del JSON)
  /// a tipo `double` para asegurar consistencia en los cálculos.
  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      currentBalance: (json['currentBalance'] as num).toDouble(),
      totalIncomeThisMonth: (json['totalIncomeThisMonth'] as num).toDouble(),
      totalExpensesThisMonth: (json['totalExpensesThisMonth'] as num).toDouble(),
    );
  }

  /// **Método `toJson`** para convertir una instancia de `DashboardSummary` a un mapa JSON.
  ///
  /// Este método es útil si necesitas serializar el objeto `DashboardSummary`
  /// de nuevo a un formato JSON, por ejemplo, para almacenamiento local o para
  /// enviar datos a otra parte de la aplicación o a un backend (aunque es menos común
  /// para objetos de resumen que son principalmente para visualización).
  Map<String, dynamic> toJson() {
    return {
      'currentBalance': currentBalance,
      'totalIncomeThisMonth': totalIncomeThisMonth,
      'totalExpensesThisMonth': totalExpensesThisMonth,
    };
  }
}