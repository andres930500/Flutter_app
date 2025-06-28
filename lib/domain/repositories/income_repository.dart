import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo de datos para los ingresos.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo para datos mensuales agregados.

/// `IncomeRepository` es una **interfaz abstracta** que define el contrato
/// para las operaciones relacionadas con la gestión de ingresos.
///
/// Esta interfaz especifica qué funcionalidades deben estar disponibles para
/// interactuar con los datos de ingresos, sin preocuparse por los detalles
/// de la implementación subyacente (ej. si los datos provienen de una API
/// o una base de datos local). Esto fomenta una arquitectura limpia y la
/// separación de responsabilidades en tu aplicación.
abstract class IncomeRepository {
  /// Crea un nuevo ingreso en el sistema.
  ///
  /// Recibe un objeto `Income` que contiene los datos del nuevo ingreso.
  /// Retorna un `Future<bool>` indicando si la operación de creación fue exitosa.
  Future<bool> createIncome(Income income);

  /// Obtiene una lista de **ingresos agrupados por mes** para un `presupuestoId` específico.
  ///
  /// Esto es útil para visualizar cómo se distribuyen los ingresos a lo largo
  /// del tiempo dentro de un presupuesto dado. El resultado se presenta como una
  /// lista de `MonthlyData`, donde cada elemento contiene el nombre del mes
  /// y el monto total de ingresos para ese período.
  /// Retorna un `Future` que resuelve en una `List<MonthlyData>`.
  Future<List<MonthlyData>> getIngresosPorPresupuesto(int presupuestoId);
}