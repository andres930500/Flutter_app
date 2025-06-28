import 'package:money_mind_mobile/domain/repositories/budget_repository.dart'; // Importa la interfaz del repositorio de presupuestos.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de presupuesto.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.

/// Implementación concreta de `BudgetRepository` que interactúa con un servicio API.
///
/// Esta clase es responsable de manejar las operaciones de datos relacionadas con los presupuestos,
/// actuando como un intermediario entre la lógica de negocio de la aplicación y la fuente de datos
/// remota (en este caso, una API RESTful a través de `ApiService`).
class BudgetRepositoryImpl implements BudgetRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService _apiService;

  /// Constructor de `BudgetRepositoryImpl`.
  ///
  /// Requiere una instancia de `ApiService` para su inicialización,
  /// lo que permite inyectar la dependencia del servicio API.
  BudgetRepositoryImpl(this._apiService);

  /// Obtiene una lista de presupuestos para un usuario específico.
  ///
  /// Delega la llamada al método `getBudgetsByUser` del `_apiService`.
  @override
  Future<List<Budget>> getBudgetsByUser(int usuarioId) async {
    return await _apiService.getBudgetsByUser(usuarioId);
  }

  /// Obtiene un presupuesto específico por su ID.
  ///
  /// Delega la llamada al método `getBudgetById` del `_apiService`.
  @override
  Future<Budget?> getBudgetById(int id) async {
    return await _apiService.getBudgetById(id);
  }

  /// Crea un nuevo presupuesto en el backend.
  ///
  /// Delega la llamada al método `createBudget` del `_apiService`.
  @override
  Future<bool> createBudget(Budget budget) async {
    return await _apiService.createBudget(budget);
  }

  /// Actualiza un presupuesto existente en el backend.
  ///
  /// Delega la llamada al método `updateBudget` del `_apiService`.
  @override
  Future<bool> updateBudget(Budget budget) async {
    return await _apiService.updateBudget(budget);
  }

  /// Elimina un presupuesto del backend por su ID.
  ///
  /// Delega la llamada al método `deleteBudget` del `_apiService`.
  @override
  Future<bool> deleteBudget(int id) async {
    return await _apiService.deleteBudget(id);
  }
  
  /// Obtiene una lista de presupuestos para un usuario específico y un mes dado.
  ///
  /// Delega la llamada al método `getBudgetsByUserAndMonth` del `_apiService`.
  @override
  Future<List<Budget>> getBudgetsByUserAndMonth(int usuarioId, String mes) async {
    return await _apiService.getBudgetsByUserAndMonth(usuarioId, mes);
  }
}