import 'package:money_mind_mobile/domain/repositories/expense_repository.dart'; // Importa la interfaz del repositorio de gastos.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.

/// **`GetExpenseByIdUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **recuperación de un gasto específico por su identificador**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación del resto
/// de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetExpenseByIdUseCase {
  /// Instancia del repositorio de gastos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de obtención de datos.
  final ExpenseRepository repository;

  /// Constructor de `GetExpenseByIdUseCase`.
  ///
  /// Recibe una implementación de `ExpenseRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetExpenseByIdUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener un gasto.
  ///
  /// Recibe el `id` del gasto que se desea recuperar. Delega la llamada
  /// a la capa del repositorio para realizar la consulta.
  ///
  /// Retorna un `Future<Expense?>`:
  /// - Un objeto `Expense` si se encuentra un gasto con el `id` proporcionado.
  /// - `null` si no existe un gasto con ese `id`.
  Future<Expense?> execute(int id) {
    return repository.getExpenseById(id);
  }
}