import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.
import 'package:money_mind_mobile/domain/repositories/budget_repository.dart'; // Importa la interfaz del repositorio de presupuestos.

/// **`GetBudgetsUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **recuperación de todos los presupuestos de un usuario específico**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación del resto
/// de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetBudgetsUseCase {
  /// Instancia del repositorio de presupuestos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de obtención de datos.
  final BudgetRepository repository;

  /// Constructor de `GetBudgetsUseCase`.
  ///
  /// Recibe una implementación de `BudgetRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetBudgetsUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener los presupuestos.
  ///
  /// Recibe el `usuarioId` del usuario para el que se desean recuperar los presupuestos.
  /// Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<List<Budget>>` que contiene una lista de objetos `Budget`
  /// asociados al usuario proporcionado.
  Future<List<Budget>> execute(int usuarioId) {
    return repository.getBudgetsByUser(usuarioId);
  }
}