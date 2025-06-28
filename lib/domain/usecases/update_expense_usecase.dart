import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.

/// **`UpdateExpenseUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **actualización de un gasto existente**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class UpdateExpenseUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de actualización.
  final ExpenseRepository repository;

  /// Constructor de `UpdateExpenseUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  UpdateExpenseUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de actualizar un gasto.
  ///
  /// Recibe un objeto `Expense` que contiene los datos actualizados del gasto.
  /// El `id` dentro de este objeto `Expense` es crucial para identificar cuál
  /// gasto debe ser modificado. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el gasto fue actualizado exitosamente.
  /// - `false` si hubo algún problema durante la actualización o no se encontró el gasto.
  Future<bool> execute(Expense expense) {
    return repository.updateExpense(expense);
  }
}