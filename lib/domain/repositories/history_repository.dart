// lib/domain/repositories/history_repository.dart

import 'package:money_mind_mobile/data/models/transaction_history_item_model.dart'; // Importa el modelo unificado para elementos del historial.

/// `HistoryRepository` es una **interfaz abstracta** que define el contrato
/// para las operaciones relacionadas con la obtención del historial de transacciones.
///
/// Esta interfaz especifica qué funcionalidades deben estar disponibles para
/// acceder y gestionar los datos de ingresos y gastos de forma combinada,
/// sin preocuparse por los detalles de cómo se implementan (por ejemplo,
/// si los datos provienen de una API, una base de datos local, etc.).
/// Esto promueve una arquitectura limpia y la separación de responsabilidades.
abstract class HistoryRepository {
  /// Obtiene una lista de todas las transacciones (ingresos y gastos) para un usuario.
  ///
  /// Permite filtrar las transacciones por un rango de fechas opcional.
  ///
  /// Parámetros:
  /// - `usuarioId`: El **ID del usuario** del que se quiere obtener el historial de transacciones. Este campo es **obligatorio**.
  /// - `startDate`: (Opcional) La **fecha de inicio** para filtrar las transacciones. Si se proporciona, solo se incluirán las transacciones que ocurrieron en o después de esta fecha.
  /// - `endDate`: (Opcional) La **fecha de fin** para filtrar las transacciones. Si se proporciona, solo se incluirán las transacciones que ocurrieron en o antes de esta fecha.
  ///
  /// Retorna un `Future` que resuelve en una `List<TransactionHistoryItem>`,
  /// la cual contendrá tanto los ingresos como los gastos del usuario,
  /// posiblemente filtrados por el rango de fechas especificado.
  Future<List<TransactionHistoryItem>> getTransactionsHistory({
    required int usuarioId,
    DateTime? startDate,
    DateTime? endDate,
  });
}