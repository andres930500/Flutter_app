import 'package:money_mind_mobile/domain/repositories/chart_repository.dart'; // Importa la interfaz del repositorio de gráficos.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.
import 'package:money_mind_mobile/data/models/category_total.dart'; // Importa el modelo de totales por categoría.

/// Implementación concreta de `ChartRepository` que interactúa con un servicio API.
///
/// Esta clase es responsable de obtener los datos agregados necesarios para los gráficos
/// del dashboard, actuando como un intermediario entre la lógica de negocio y el `ApiService`.
class DashboardRepositoryImpl implements ChartRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService apiService;

  /// Constructor de `DashboardRepositoryImpl`.
  ///
  /// Requiere una instancia de `ApiService` para su inicialización,
  /// lo que permite inyectar la dependencia del servicio API.
  DashboardRepositoryImpl(this.apiService);

  /// Obtiene los datos de gastos totales por mes para un usuario específico.
  ///
  /// Delega la llamada al método `getGastosPorMes` del `apiService`.
  @override
  Future<List<MonthlyData>> getGastosPorMes(int usuarioId) {
    return apiService.getGastosPorMes(usuarioId);
  }

  /// Obtiene los datos de ingresos totales por mes para un usuario específico.
  ///
  /// Delega la llamada al método `getIngresosPorMes` del `apiService`.
  @override
  Future<List<MonthlyData>> getIngresosPorMes(int usuarioId) {
    return apiService.getIngresosPorMes(usuarioId);
  }

  /// Obtiene los datos de gastos totales por categoría para un usuario y mes específicos.
  ///
  /// Delega la llamada al método `getGastosPorCategoria` del `apiService`.
  @override
  Future<List<CategoryTotal>> getGastosPorCategoria(int usuarioId, String mes) {
    return apiService.getGastosPorCategoria(usuarioId, mes);
  }
}