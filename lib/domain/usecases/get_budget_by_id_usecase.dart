import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.
import 'package:money_mind_mobile/domain/repositories/budget_repository.dart'; // Importa la interfaz del repositorio de presupuestos.

/// **`GetBudgetByIdUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **recuperación de un presupuesto específico por su identificador**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetBudgetByIdUseCase {
  /// Instancia del repositorio de presupuestos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de obtención de datos.
  final BudgetRepository repository;

  /// Constructor de `GetBudgetByIdUseCase`.
  ///
  /// Recibe una implementación de `BudgetRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetBudgetByIdUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener un presupuesto.
  ///
  /// Recibe el `id` del presupuesto que se desea recuperar. Delega la llamada
  /// a la capa del repositorio para realizar la consulta.
  ///
  /// Retorna un `Future<Budget?>`:
  /// - Un objeto `Budget` si se encuentra un presupuesto con el `id` proporcionado.
  /// - `null` si no existe un presupuesto con ese `id`.
  Future<Budget?> execute(int id) async {
    return await repository.getBudgetById(id);
  }
}