import 'package:money_mind_mobile/domain/repositories/category_repository.dart'; // Importa la interfaz del repositorio de categorías.
import 'package:money_mind_mobile/data/models/category_model.dart'; // Importa el modelo de categoría.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.

/// Implementación concreta de `CategoryRepository` que interactúa con un servicio API.
///
/// Esta clase es responsable de manejar las operaciones de datos relacionadas con las categorías,
/// actuando como un puente entre la lógica de negocio de la aplicación y la fuente de datos
/// remota (en este caso, una API RESTful a través de `ApiService`).
class CategoryRepositoryImpl implements CategoryRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  final ApiService _apiService;

  /// Constructor de `CategoryRepositoryImpl`.
  ///
  /// Requiere una instancia de `ApiService` para su inicialización,
  /// lo que permite inyectar la dependencia del servicio API.
  CategoryRepositoryImpl(this._apiService);

  /// Obtiene una lista de todas las categorías disponibles.
  ///
  /// Delega la llamada al método `getCategories` del `_apiService`.
  @override
  Future<List<Category>> getCategories() {
    return _apiService.getCategories();
  }

  /// Crea una nueva categoría en el backend.
  ///
  /// Delega la llamada al método `createCategory` del `_apiService`, que es un método nuevo
  /// encargado de enviar los datos de la nueva categoría a la API.
  @override
  Future<bool> createCategory(Category category) {
    return _apiService.createCategory(category);
  }
}