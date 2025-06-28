import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo para datos mensuales agregados.
import 'package:money_mind_mobile/data/models/category_total.dart'; // Importa el modelo para totales por categoría.

/// `ChartRepository` es una **interfaz abstracta** que define el contrato
/// para los métodos que proporcionan datos agregados, específicamente para
/// la visualización en gráficos del dashboard.
///
/// Esta interfaz asegura que cualquier implementación de este repositorio
/// pueda obtener los resúmenes financieros necesarios, manteniendo la lógica
/// de la aplicación desacoplada de la fuente de datos subyacente.
abstract class ChartRepository {
  /// Obtiene una lista de **gastos agrupados por mes** para un `usuarioId` específico.
  ///
  /// El resultado se presenta como una lista de `MonthlyData`, donde cada elemento
  /// contiene el nombre del mes y el monto total de gastos para ese período.
  /// Retorna un `Future` que resuelve en una `List<MonthlyData>`.
  Future<List<MonthlyData>> getGastosPorMes(int usuarioId);

  /// Obtiene una lista de **ingresos agrupados por mes** para un `usuarioId` específico.
  ///
  /// Similar a los gastos, el resultado es una lista de `MonthlyData` con el mes
  /// y el monto total de ingresos para dicho período.
  /// Retorna un `Future` que resuelve en una `List<MonthlyData>`.
  Future<List<MonthlyData>> getIngresosPorMes(int usuarioId);

  /// Obtiene una lista de **gastos agrupados por categoría** para un `usuarioId` y `mes` específicos.
  ///
  /// El `mes` debe estar en un formato que el sistema pueda interpretar (ej., "2024-06").
  /// El resultado es una lista de `CategoryTotal`, indicando el nombre de la categoría
  /// y el monto total gastado en ella para el mes dado.
  /// Retorna un `Future` que resuelve en una `List<CategoryTotal>`.
  Future<List<CategoryTotal>> getGastosPorCategoria(int usuarioId, String mes);
}