// lib/features/expenses/repositories/expense_repository_impl.dart

import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de Gasto.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales (usado para agregaciones).
import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.
import 'package:flutter/foundation.dart'; // Para `debugPrint`

/// Implementación concreta de `ExpenseRepository` que interactúa con un servicio API.
///
/// Esta clase maneja las operaciones de datos relacionadas con los gastos,
/// sirviendo como intermediario entre la lógica de negocio de la aplicación
/// y la fuente de datos remota (a través de `ApiService`).
class ExpenseRepositoryImpl implements ExpenseRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService _apiService;

  /// Constructor de `ExpenseRepositoryImpl`.
  ///
  /// Requiere una instancia de `ApiService` para su inicialización,
  /// lo que permite inyectar la dependencia del servicio API.
  ExpenseRepositoryImpl(this._apiService);

  /// Crea un nuevo gasto en el backend.
  ///
  /// Delega la operación al método `postExpense` del `_apiService`.
  @override
  Future<bool> createExpense(Expense expense) async {
    try {
      final success = await _apiService.postExpense(expense);
      if (!success) {
        debugPrint('Error: La creación del gasto no fue exitosa en la API.');
      }
      return success;
    } catch (e) {
      debugPrint('Error en createExpense (repository): $e');
      return false;
    }
  }

  /// Obtiene un gasto específico por su ID.
  ///
  /// Llama al método `getExpenseById` del `_apiService`.
  @override
  Future<Expense?> getExpenseById(int id) async {
    try {
      return await _apiService.getExpenseById(id);
    } catch (e) {
      debugPrint('Error en getExpenseById (repository): $e');
      // Puedes lanzar la excepción o retornar null/manejar el error según tu estrategia.
      return null;
    }
  }

  /// Actualiza un gasto existente en el backend.
  ///
  /// Llama al método `updateExpense` del `_apiService`.
  /// Esta operación es crítica para que el backend dispare las notificaciones
  /// si el presupuesto se ve afectado.
  @override
  Future<bool> updateExpense(Expense expense) async {
    try {
      final success = await _apiService.updateExpense(expense);
      if (!success) {
        debugPrint('Error: La actualización del gasto no fue exitosa en la API.');
      }
      return success;
    } catch (e) {
      debugPrint('Error en updateExpense (repository): $e');
      return false;
    }
  }

  /// Elimina un gasto del backend por su ID.
  ///
  /// Llama al método `deleteExpense` del `_apiService`.
  /// Esta operación también es crítica para que el backend recalcule
  /// el estado del presupuesto y potencialmente envíe notificaciones.
  @override
  Future<bool> deleteExpense(int id) async {
    try {
      final success = await _apiService.deleteExpense(id);
      if (!success) {
        debugPrint('Error: La eliminación del gasto no fue exitosa en la API.');
      }
      return success;
    } catch (e) {
      debugPrint('Error en deleteExpense (repository): $e');
      return false;
    }
  }

  /// Obtiene una lista de todos los gastos para un usuario específico.
  ///
  /// **CORREGIDO:** Ahora llama directamente a `_apiService.getExpensesByUser()`,
  /// que ya filtra los gastos en el backend, mejorando la eficiencia.
  @override
  Future<List<Expense>> getExpenses(int usuarioId) async {
    try {
      // Usamos el método optimizado del ApiService que filtra por usuario en el backend
      final expenses = await _apiService.getExpensesByUser(usuarioId);
      return expenses;
    } catch (e) {
      debugPrint('Error en getExpenses (repository) para usuario $usuarioId: $e');
      throw Exception('Error al obtener gastos del usuario: $e');
    }
  }

  /// Obtiene los gastos agregados por mes para un presupuesto específico.
  ///
  /// Delega la llamada al método `getGastosPorPresupuesto` del `_apiService`.
  @override
  Future<List<MonthlyData>> getGastosPorPresupuesto(int presupuestoId) {
    try {
      return _apiService.getGastosPorPresupuesto(presupuestoId);
    } catch (e) {
      debugPrint('Error en getGastosPorPresupuesto (repository): $e');
      // Puedes manejar el error aquí si quieres o dejar que lo manejen las capas superiores.
      throw e;
    }
  }
}
