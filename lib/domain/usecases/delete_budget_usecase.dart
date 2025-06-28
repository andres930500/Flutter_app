import 'package:money_mind_mobile/domain/repositories/budget_repository.dart'; // Importa la interfaz del repositorio de presupuestos.

/// **`DeleteBudgetUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **eliminación de un presupuesto existente**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class DeleteBudgetUseCase {
  /// Instancia del repositorio de presupuestos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de eliminación.
  final BudgetRepository repository;

  /// Constructor de `DeleteBudgetUseCase`.
  ///
  /// Recibe una implementación de `BudgetRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  DeleteBudgetUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de eliminar un presupuesto.
  ///
  /// Recibe el `id` del presupuesto que se desea eliminar. Delega la llamada
  /// a la capa del repositorio para realizar la eliminación.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el presupuesto fue eliminado exitosamente.
  /// - `false` si hubo algún problema durante la eliminación o no se encontró el presupuesto.
  Future<bool> execute(int id) async {
    return await repository.deleteBudget(id);
  }
}