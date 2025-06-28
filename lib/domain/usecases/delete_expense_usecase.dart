import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.

/// **`DeleteExpenseUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **eliminación de un gasto existente**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class DeleteExpenseUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de eliminación.
  final ExpenseRepository repository;

  /// Constructor de `DeleteExpenseUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  DeleteExpenseUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de eliminar un gasto.
  ///
  /// Recibe el `id` del gasto que se desea eliminar. Delega la llamada
  /// a la capa del repositorio para realizar la eliminación.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el gasto fue eliminado exitosamente.
  /// - `false` si hubo algún problema durante la eliminación o no se encontró el gasto.
  Future<bool> execute(int id) {
    return repository.deleteExpense(id);
  }
}