import 'package:money_mind_mobile/domain/repositories/category_repository.dart'; // Importa la interfaz del repositorio de categorías.
import 'package:money_mind_mobile/data/models/category_model.dart'; // Importa el modelo de datos para las categorías.

/// **`CreateCategoryUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **creación de una nueva categoría**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class CreateCategoryUseCase {
  /// Instancia del repositorio de categorías.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de creación.
  final CategoryRepository _repository;

  /// Constructor de `CreateCategoryUseCase`.
  ///
  /// Recibe una implementación de `CategoryRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o diferentes fuentes de datos).
  CreateCategoryUseCase(this._repository);

  /// Método `execute` que lleva a cabo la operación de crear una categoría.
  ///
  /// Recibe un objeto `Category` que contiene todos los detalles de la categoría
  /// que se desea crear. Delega la llamada a la capa del repositorio.
  ///
  /// Retorna un `Future<bool>`:
  /// - `true` si la categoría fue creada exitosamente.
  /// - `false` si hubo algún problema durante la creación.
  Future<bool> execute(Category category) {
    return _repository.createCategory(category);
  }
}