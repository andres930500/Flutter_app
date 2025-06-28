import 'package:flutter/material.dart'; // Importa las herramientas básicas de Material Design y los widgets de Flutter.
import 'package:money_mind_mobile/api/models/category_model.dart'; // Importa el modelo de datos para una categoría.
import 'package:money_mind_mobile/domain/usecases/get_categories_usecase.dart'; // Importa el caso de uso para obtener categorías.

/// **`CategoryProvider`** es un `ChangeNotifier` que se encarga de gestionar el estado
/// y la lógica para obtener y proveer las categorías disponibles en la aplicación MoneyMind.
///
/// Actúa como un intermediario entre la interfaz de usuario y el caso de uso que
/// recupera los datos de las categorías, manteniendo la UI actualizada.
class CategoryProvider extends ChangeNotifier {
  // --- Dependencia: Caso de Uso (Use Case) ---
  /// El caso de uso para obtener todas las categorías. Se inyecta a través del constructor
  /// para mejorar la modularidad, facilitar las pruebas y aumentar la flexibilidad.
  final GetCategoriesUseCase _getCategoriesUseCase;

  /// Constructor de `CategoryProvider`.
  ///
  /// Recibe una instancia de `GetCategoriesUseCase` que utilizará para
  /// la obtención de categorías.
  CategoryProvider(this._getCategoriesUseCase);

  // --- Variables de Estado Internas ---
  /// Lista que contendrá todos los objetos `Category` obtenidos.
  /// Se inicializa como una lista vacía.
  List<Category> _categories = [];

  /// Indicador booleano que señala si una operación de carga de categorías está en curso.
  /// Útil para mostrar estados de carga en la UI.
  bool _isLoading = false;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso a la lista actual de categorías.
  List<Category> get categories => _categories;

  /// Proporciona acceso al estado de carga actual.
  /// `true` si se están cargando categorías, `false` en caso contrario.
  bool get isLoading => _isLoading;

  // --- Métodos para la Lógica de Negocio ---

  /// **Carga las categorías** desde la capa de dominio.
  ///
  /// Este método es el punto de entrada para que la UI solicite la obtención de categorías.
  /// Gestiona el estado de carga y notifica a los oyentes sobre los cambios.
  Future<void> loadCategories() async {
    // 1. Inicia el estado de carga:
    _isLoading = true; // Establece el indicador de carga a `true`.
    notifyListeners(); // Notifica a todos los widgets que escuchan que la carga ha comenzado,
                        // permitiendo a la UI mostrar un indicador de progreso (ej. `CircularProgressIndicator`).

    try {
      // 2. Ejecuta el caso de uso:
      // Delega la responsabilidad de obtener las categorías al `_getCategoriesUseCase`.
      // El `await` pausa la ejecución hasta que el caso de uso retorna la lista de categorías.
      _categories = await _getCategoriesUseCase.execute();
      // En un entorno de producción, aquí se podría añadir un `debugPrint` para loguear el éxito o el número de categorías cargadas.
    } catch (e) {
      // 3. Manejo de errores:
      // Si ocurre alguna excepción durante la obtención de las categorías, se captura aquí.
      debugPrint('Error al cargar categorías en el provider: $e'); // Loguea el error.
      _categories = []; // En caso de error, la lista de categorías se vacía para
                        // asegurar un estado consistente en la UI.
    } finally {
      // 4. Finaliza el estado de carga:
      // Este bloque se ejecuta siempre, independientemente de si la carga fue exitosa o falló.
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a la UI que la operación de carga ha finalizado,
                          // permitiendo ocultar el indicador de progreso o actualizar la vista con las categorías obtenidas (o una lista vacía si hubo error).
    }
  }
}