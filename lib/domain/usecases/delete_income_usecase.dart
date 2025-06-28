// lib/domain/usecases/delete_income_usecase.dart

import 'package:money_mind_mobile/domain/repositories/history_repository.dart'; // O el repositorio que maneje la eliminación de ingresos

/// **`DeleteIncomeUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **eliminación de un ingreso**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class DeleteIncomeUseCase {
  /// Instancia del repositorio que maneja las operaciones relacionadas con el historial,
  /// y por extensión, la eliminación de ingresos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de eliminación.
  final HistoryRepository repository; // Se asume que HistoryRepository manejará esta operación.

  /// Constructor de `DeleteIncomeUseCase`.
  ///
  /// Recibe una implementación de `HistoryRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  DeleteIncomeUseCase(this.repository);

  /// El método `execute` es el punto de entrada para esta lógica.
  ///
  /// Recibe el `incomeId` (identificador único del ingreso) que se desea eliminar.
  /// Delega la llamada a la capa del repositorio para realizar la eliminación.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el ingreso fue eliminado exitosamente.
  /// - `false` si hubo algún problema durante la eliminación o no se encontró el ingreso.
  Future<bool> execute(int incomeId) async {
    // Delega la llamada al repositorio.
    return await repository.deleteIncome(incomeId);
  }
}