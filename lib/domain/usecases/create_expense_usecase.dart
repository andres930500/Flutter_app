import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.
import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.

/// **`CreateExpenseUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **creación de un nuevo gasto**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class CreateExpenseUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de creación.
  final ExpenseRepository repository;

  /// Constructor de `CreateExpenseUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  CreateExpenseUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de crear un gasto.
  ///
  /// Recibe un objeto `Expense` que contiene todos los detalles del gasto
  /// que se desea registrar. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el gasto fue creado exitosamente.
  /// - `false` si hubo algún problema durante la creación.
  Future<bool> execute(Expense expense) {
    return repository.createExpense(expense);
  }
}