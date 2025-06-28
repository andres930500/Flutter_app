import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo de datos para los ingresos.
import 'package:money_mind_mobile/domain/repositories/income_repository.dart'; // Importa la interfaz del repositorio de ingresos.

/// **`CreateIncomeUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **creación de un nuevo ingreso**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class CreateIncomeUseCase {
  /// Instancia del repositorio de ingresos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de creación.
  final IncomeRepository repository;

  /// Constructor de `CreateIncomeUseCase`.
  ///
  /// Recibe una implementación de `IncomeRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  CreateIncomeUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de crear un ingreso.
  ///
  /// Recibe un objeto `Income` que contiene todos los detalles del ingreso
  /// que se desea registrar. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si el ingreso fue creado exitosamente.
  /// - `false` si hubo algún problema durante la creación.
  Future<bool> execute(Income income) {
    return repository.createIncome(income); // Asegúrate de que este método exista en el repositorio.
  }
}