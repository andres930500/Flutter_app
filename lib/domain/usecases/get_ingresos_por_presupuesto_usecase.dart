import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API (aunque no se usa directamente aquí, es una dependencia implícita a través del repositorio).
import 'package:money_mind_mobile/domain/repositories/income_repository.dart'; // Importa la interfaz del repositorio de ingresos.

/// **`GetIngresosPorPresupuestoUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **obtención de ingresos agregados por mes para un presupuesto específico**.
///
/// Este caso de uso es útil para visualizar cómo los ingresos asociados a un
/// determinado presupuesto se distribuyen a lo largo del tiempo, por ejemplo, en gráficos o reportes.
class GetIngresosPorPresupuestoUseCase {
  /// Instancia del repositorio de ingresos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para obtener la información de los ingresos.
  final IncomeRepository repository;

  /// Constructor de `GetIngresosPorPresupuestoUseCase`.
  ///
  /// Recibe una implementación de `IncomeRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetIngresosPorPresupuestoUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener los ingresos por presupuesto.
  ///
  /// Recibe el `presupuestoId` del presupuesto para el que se desean recuperar
  /// los datos de ingresos agregados. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<List<MonthlyData>>` que contendrá una lista de objetos
  /// `MonthlyData`, donde cada uno representa el total de ingresos para un mes
  /// específico dentro del presupuesto dado.
  Future<List<MonthlyData>> execute(int presupuestoId) {
    return repository.getIngresosPorPresupuesto(presupuestoId);
  }
}