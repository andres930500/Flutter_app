import 'package:money_mind_mobile/data/models/category_model.dart'; // Importa el modelo de datos para las categorías.

/// `CategoryRepository` es una **interfaz abstracta** que define el contrato
/// para las operaciones relacionadas con la gestión de categorías.
///
/// Esta interfaz establece qué funcionalidades deben estar disponibles para
/// interactuar con los datos de categorías, sin especificar los detalles
/// de su implementación (por ejemplo, si los datos provienen de una API,
/// una base de datos local, etc.). Esto fomenta una arquitectura limpia
/// y la separación de responsabilidades.
abstract class CategoryRepository {
  /// Obtiene una lista de todas las categorías disponibles.
  ///
  /// Retorna un `Future` que resuelve en una `List` de objetos `Category`.
  Future<List<Category>> getCategories();

  /// Crea una nueva categoría en el sistema.
  ///
  /// Recibe un objeto `Category` que contiene los datos de la nueva categoría.
  /// Retorna un `Future<bool>` indicando si la operación de creación fue exitosa.
  Future<bool> createCategory(Category category); // 👈 Método para crear una nueva categoría.
}