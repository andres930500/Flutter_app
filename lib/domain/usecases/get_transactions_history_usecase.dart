// lib/domain/usecases/get_transactions_history_usecase.dart

import 'package:money_mind_mobile/data/models/transaction_history_item_model.dart'; // Importa el modelo unificado para elementos del historial.
import 'package:money_mind_mobile/domain/repositories/history_repository.dart'; // Importa la interfaz del repositorio del historial.

/// **`GetTransactionsHistoryUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **obtención del historial combinado de transacciones (ingresos y gastos)**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación del resto
/// de la aplicación, haciéndola más modular, mantenible y fácil de probar.
/// Su función es coordinar el acceso a los datos sin contener lógica de API ni de UI.
class GetTransactionsHistoryUseCase {
  /// Instancia del repositorio del historial.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para obtener la información de las transacciones.
  final HistoryRepository repository;

  /// Constructor de `GetTransactionsHistoryUseCase`.
  ///
  /// Recibe una implementación de `HistoryRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetTransactionsHistoryUseCase(this.repository);

  /// El método `execute` es el punto de entrada para esta lógica de negocio.
  ///
  /// Recibe los siguientes parámetros:
  /// - `usuarioId`: El **ID del usuario** del que se quiere obtener el historial de transacciones. Es **obligatorio**.
  /// - `startDate`: (Opcional) La **fecha de inicio** para filtrar las transacciones. Solo se incluirán las transacciones en o después de esta fecha.
  /// - `endDate`: (Opcional) La **fecha de fin** para filtrar las transacciones. Solo se incluirán las transacciones en o antes de esta fecha.
  ///
  /// Delega la llamada al método `getTransactionsHistory` de la capa del repositorio,
  /// pasando los parámetros de filtrado directamente.
  ///
  /// Retorna un `Future<List<TransactionHistoryItem>>` que contendrá una lista
  /// de objetos `TransactionHistoryItem` (ingresos y gastos combinados),
  /// posiblemente filtrados y ordenados por fecha.
  Future<List<TransactionHistoryItem>> execute({
    required int usuarioId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Delega la llamada al repositorio para obtener los datos.
    return await repository.getTransactionsHistory(
      usuarioId: usuarioId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}