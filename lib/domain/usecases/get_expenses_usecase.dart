import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.

/// **`GetExpensesUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **recuperación de todos los gastos de un usuario específico**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación del resto
/// de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetExpensesUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de obtención de datos.
  final ExpenseRepository repository;

  /// Constructor de `GetExpensesUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetExpensesUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener los gastos.
  ///
  /// Recibe el `usuarioId` del usuario para el que se desean recuperar los gastos.
  /// Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<List<Expense>>` que contendrá una lista de todos los
  /// objetos `Expense` asociados al usuario proporcionado.
  Future<List<Expense>> execute(int usuarioId) {
    return repository.getExpenses(usuarioId); // Asegúrate que este método existe en `ExpenseRepository`.
  }
}