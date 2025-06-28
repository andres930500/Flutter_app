import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.
import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo de Ingreso.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales (usado para agregaciones).
import 'package:money_mind_mobile/domain/repositories/income_repository.dart'; // Importa la interfaz del repositorio de ingresos.

/// Implementación concreta de `IncomeRepository` que interactúa con un servicio API.
///
/// Esta clase es responsable de manejar las operaciones de datos relacionadas con los ingresos,
/// sirviendo como intermediario entre la lógica de negocio de la aplicación
/// y la fuente de datos remota (a través de `ApiService`).
class IncomeRepositoryImpl implements IncomeRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService _apiService;

  /// Constructor de `IncomeRepositoryImpl`.
  ///
  /// Requiere una instancia de `ApiService` para su inicialización,
  /// lo que permite inyectar la dependencia del servicio API.
  IncomeRepositoryImpl(this._apiService);

  /// Crea un nuevo ingreso en el backend.
  ///
  /// Delega la operación al método `createIncome` del `_apiService`.
  @override
  Future<bool> createIncome(Income income) {
    return _apiService.createIncome(income);
  }

  /// Obtiene los ingresos agregados por mes para un presupuesto específico.
  ///
  /// Delega la llamada al método `getIngresosPorPresupuesto` del `_apiService`.
  @override
  Future<List<MonthlyData>> getIngresosPorPresupuesto(int presupuestoId) {
    return _apiService.getIngresosPorPresupuesto(presupuestoId);
  }
}