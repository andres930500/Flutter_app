import 'package:money_mind_mobile/domain/repositories/category_repository.dart'; // Importa la interfaz del repositorio de categorías.
import 'package:money_mind_mobile/data/models/category_model.dart'; // Importa el modelo de datos para las categorías.

/// **`GetCategoriesUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **recuperación de todas las categorías disponibles**.
///
/// Este patrón de diseño (Use Case) aísla la lógica de la operación del resto
/// de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetCategoriesUseCase {
  /// Instancia del repositorio de categorías.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para realizar la operación de obtención de datos.
  final CategoryRepository _categoryRepository;

  /// Constructor de `GetCategoriesUseCase`.
  ///
  /// Recibe una implementación de `CategoryRepository` (inyectada), lo que
  /// permite la **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetCategoriesUseCase(this._categoryRepository);

  /// Método `execute` que lleva a cabo la operación de obtener las categorías.
  ///
  /// Delega la llamada a la capa del repositorio para recuperar la lista de categorías.
  ///
  /// Retorna un `Future<List<Category>>` que contendrá una lista de todos los
  /// objetos `Category` disponibles.
  Future<List<Category>> execute() {
    return _categoryRepository.getCategories();
  }
}