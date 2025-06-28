import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.
import 'package:money_mind_mobile/domain/repositories/budget_repository.dart'; // Importa la interfaz del repositorio de presupuestos.

/// **`UpdateBudgetUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **actualización de un presupuesto existente**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class UpdateBudgetUseCase {
  /// Instancia del repositorio de presupuestos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de actualización.
  final BudgetRepository repository;

  /// Constructor de `UpdateBudgetUseCase`.
  ///
  /// Recibe una implementación de `BudgetRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  UpdateBudgetUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de actualizar un presupuesto.
  ///
  /// Recibe un objeto `Budget` que contiene los datos actualizados del presupuesto.
  /// El `id` dentro de este objeto `Budget` es crucial para identificar cuál
  /// presupuesto debe ser modificado. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el presupuesto fue actualizado exitosamente.
  /// - `false` si hubo algún problema durante la actualización o no se encontró el presupuesto.
  Future<bool> execute(Budget budget) async {
    return await repository.updateBudget(budget);
  }
}