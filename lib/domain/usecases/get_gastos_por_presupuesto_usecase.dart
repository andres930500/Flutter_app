import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API (aunque no se usa directamente aquí, es una dependencia implícita a través del repositorio).
import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.

/// **`GetGastosPorPresupuestoUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **obtención de gastos agregados por mes para un presupuesto específico**.
///
/// Este caso de uso es útil para visualizar cómo los gastos de un determinado
/// presupuesto se distribuyen a lo largo del tiempo, por ejemplo, en gráficos o reportes.
class GetGastosPorPresupuestoUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para obtener la información de los gastos.
  final ExpenseRepository repository;

  /// Constructor de `GetGastosPorPresupuestoUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  GetGastosPorPresupuestoUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener los gastos por presupuesto.
  ///
  /// Recibe el `presupuestoId` del presupuesto para el que se desean recuperar
  /// los datos de gastos agregados. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<List<MonthlyData>>` que contendrá una lista de objetos
  /// `MonthlyData`, donde cada uno representa el total de gastos para un mes
  /// específico dentro del presupuesto dado.
  Future<List<MonthlyData>> execute(int presupuestoId) {
    return repository.getGastosPorPresupuesto(presupuestoId);
  }
}