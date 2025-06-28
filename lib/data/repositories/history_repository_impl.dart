// lib/data/repositories/history_repository_impl.dart

import 'package:money_mind_mobile/domain/repositories/history_repository.dart'; // Importa la interfaz del repositorio del historial.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de Gasto.
import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo de Ingreso.
import 'package:money_mind_mobile/data/models/transaction_history_item_model.dart'; // Importa el modelo unificado para elementos del historial.
import 'package:flutter/foundation.dart'; // Para `debugPrint`, útil para depuración.

/// Implementación concreta de `HistoryRepository` que gestiona el historial de transacciones.
///
/// Esta clase es responsable de obtener, procesar y unificar los datos de ingresos y gastos
/// de un usuario para presentarlos como un historial de transacciones combinado.
/// Actúa como un puente entre la lógica de negocio y el `ApiService`.
class HistoryRepositoryImpl implements HistoryRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService _apiService;

  /// Constructor de `HistoryRepositoryImpl`.
  ///
  /// Permite la **inyección de dependencia** de `ApiService` para facilitar las pruebas
  /// (por ejemplo, usando un `ApiService` simulado). Si no se provee una instancia,
  /// se utiliza la instancia singleton por defecto de `ApiService`.
  HistoryRepositoryImpl({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Obtiene el historial de transacciones (ingresos y gastos) para un usuario.
  ///
  /// Permite filtrar las transacciones por un rango de fechas opcional.
  ///
  /// Parámetros:
  /// - `usuarioId`: El ID del usuario del que se quiere obtener el historial.
  /// - `startDate`: (Opcional) La fecha de inicio para filtrar las transacciones.
  /// - `endDate`: (Opcional) La fecha de fin para filtrar las transacciones.
  ///
  /// Retorna una `Future` que resuelve en una `List<TransactionHistoryItem>`
  /// con todas las transacciones combinadas y ordenadas cronológicamente (más recientes primero).
  /// Devuelve una lista vacía si ocurre algún error.
  @override
  Future<List<TransactionHistoryItem>> getTransactionsHistory({
    required int usuarioId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    List<TransactionHistoryItem> allTransactions = [];

    try {
      // 1. Obtener todos los gastos del usuario desde el servicio API.
      // Se asume que `_apiService.getExpensesByUser(usuarioId)` ya filtra por usuario en el backend.
      // En el futuro, considera añadir filtrado por fecha directamente en el backend para optimizar.
      final List<Expense> expenses = await _apiService.getExpensesByUser(usuarioId);
      debugPrint('Gastos obtenidos: ${expenses.length}');

      // 2. Obtener todos los ingresos del usuario desde el servicio API.
      // Similar a los gastos, se asume un filtrado por usuario en el backend.
      final List<Income> incomes = await _apiService.getIncomesByUser(usuarioId);
      debugPrint('Ingresos obtenidos: ${incomes.length}');

      // 3. Convertir cada objeto `Expense` a `TransactionHistoryItem` y añadirlos a la lista unificada.
      for (var expense in expenses) {
        allTransactions.add(TransactionHistoryItem.fromExpense(expense));
      }

      // 4. Convertir cada objeto `Income` a `TransactionHistoryItem` y añadirlos a la lista unificada.
      for (var income in incomes) {
        allTransactions.add(TransactionHistoryItem.fromIncome(income));
      }

      // 5. Aplicar filtros de fecha si `startDate` o `endDate` están presentes.
      if (startDate != null) {
        // Asegurarse de que el filtro incluya todas las transacciones a partir del inicio del `startDate`.
        final startOfDay = DateTime(startDate.year, startDate.month, startDate.day);
        allTransactions = allTransactions
            .where((item) => item.fecha.isAfter(startOfDay) || item.fecha.isAtSameMomentAs(startOfDay))
            .toList();
        debugPrint(
            'Transacciones después de filtro de inicio (${startDate.toIso8601String().split("T")[0]}): ${allTransactions.length}');
      }
      if (endDate != null) {
        // Asegurarse de que el filtro incluya todas las transacciones hasta el final del `endDate`.
        final endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
        allTransactions = allTransactions
            .where((item) => item.fecha.isBefore(endOfDay) || item.fecha.isAtSameMomentAs(endOfDay))
            .toList();
        debugPrint(
            'Transacciones después de filtro de fin (${endDate.toIso8601String().split("T")[0]}): ${allTransactions.length}');
      }

      // 6. Ordenar todas las transacciones combinadas por fecha en orden descendente (las más recientes primero).
      allTransactions.sort((a, b) => b.fecha.compareTo(a.fecha));

      return allTransactions;
    } catch (e) {
      // Captura cualquier error que ocurra durante el proceso y lo imprime para depuración.
      debugPrint('❌ Error en HistoryRepositoryImpl.getTransactionsHistory: $e');
      // En caso de error, se devuelve una lista vacía para evitar que la aplicación falle.
      return [];
    }
  }
}