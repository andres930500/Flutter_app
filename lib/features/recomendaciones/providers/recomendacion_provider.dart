// lib/features/recomendaciones/providers/recomendacion_provider.dart
import 'package:flutter/material.dart'; // Importa las herramientas básicas de Material Design y los widgets de Flutter.
// Asegúrate de que esta importación apunte al modelo 'Recomendacion' que tiene 'titulo' y 'descripcion'.
import 'package:money_mind_mobile/data/models/recomendacion_model.dart'; // Importa el modelo de datos para una recomendación.
import 'package:money_mind_mobile/data/repositories/recomendacion_repository_impl.dart'; // Importa la implementación del repositorio de recomendaciones.
import 'package:money_mind_mobile/domain/usecases/get_recomendaciones_usecase.dart'; // Importa el caso de uso para obtener recomendaciones.

/// **`RecomendacionProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// de negocio relacionada con la obtención y provisión de recomendaciones ecológicas
/// o financieras dentro de la aplicación MoneyMind.
///
/// Sirve como un punto centralizado para que la UI acceda a las recomendaciones
/// y se actualice cuando estas se cargan o cambian.
class RecomendacionProvider extends ChangeNotifier {
  // --- Dependencia: Caso de Uso (Use Case) ---
  /// El caso de uso para obtener recomendaciones. Se inyecta a través del constructor
  /// para promover un diseño modular, mejorar la testabilidad y la flexibilidad.
  /// Si no se provee una instancia externa, se utiliza una por defecto, inicializando
  /// el `GetRecomendacionesUseCase` con su implementación de repositorio predeterminada.
  final GetRecomendacionesUseCase _getRecomendacionesUseCase;

  /// Constructor de `RecomendacionProvider`.
  ///
  /// Permite la inyección de una instancia específica de `GetRecomendacionesUseCase`
  /// o usa la implementación por defecto si no se proporciona ninguna.
  RecomendacionProvider({
    GetRecomendacionesUseCase? getRecomendacionesUseCase,
  }) : _getRecomendacionesUseCase = getRecomendacionesUseCase ??
            GetRecomendacionesUseCase(RecomendacionRepositoryImpl());

  // --- Variables de Estado Internas ---
  /// Lista que contendrá los objetos `Recomendacion`, cada uno con su título y descripción.
  /// Se inicializa como una lista vacía.
  List<Recomendacion> _recomendaciones = [];

  /// Indicador booleano que señala si una operación de carga de recomendaciones está en curso.
  /// Esto es útil para mostrar un `CircularProgressIndicator` en la UI.
  bool _isLoading = false;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso a la lista actual de recomendaciones.
  List<Recomendacion> get recomendaciones => _recomendaciones;

  /// Proporciona acceso al estado de carga actual.
  /// `true` si se están cargando recomendaciones, `false` en caso contrario.
  bool get isLoading => _isLoading;

  // --- Métodos para la Lógica de Negocio ---

  /// **Carga las recomendaciones** desde la capa de dominio, basándose en un ID de usuario.
  ///
  /// Este método es el punto de entrada para que la UI solicite las recomendaciones.
  /// Controla el estado de carga y notifica a los oyentes sobre los cambios.
  ///
  /// * `usuarioId`: El ID del usuario para el cual se deben cargar las recomendaciones.
  ///
  /// No retorna un valor directamente, pero actualiza la lista interna `_recomendaciones`
  /// y el estado `_isLoading`.
  Future<void> loadRecomendaciones(int usuarioId) async {
    // 1. Evitar llamadas duplicadas:
    // Si ya hay una operación de carga en progreso, se sale del método para evitar
    // peticiones innecesarias o inconsistencias en el estado.
    if (_isLoading) return;

    // 2. Iniciar el estado de carga:
    _isLoading = true; // Establece el indicador de carga a `true`.
    notifyListeners(); // Notifica a todos los widgets que escuchan que la carga ha comenzado,
                        // permitiendo a la UI mostrar un indicador de progreso.

    try {
      // 3. Ejecutar el caso de uso:
      // Delega la responsabilidad de obtener las recomendaciones al `GetRecomendacionesUseCase`.
      // El `await` pausa la ejecución hasta que el caso de uso retorna la lista de recomendaciones.
      _recomendaciones = await _getRecomendacionesUseCase.execute(usuarioId);
      // Para depuración: Imprime el número de recomendaciones cargadas con éxito.
      debugPrint('Recomendaciones cargadas: ${_recomendaciones.length}');
    } catch (e) {
      // 4. Manejo de errores:
      // Si ocurre alguna excepción durante la obtención de las recomendaciones, se captura aquí.
      debugPrint(
          'Error al cargar recomendaciones en el provider: $e'); // Loguea el error.
      _recomendaciones = []; // En caso de error, la lista de recomendaciones se vacía
                             // para asegurar un estado consistente en la UI.
    } finally {
      // 5. Finalizar el estado de carga:
      // Este bloque se ejecuta siempre, independientemente de si la carga fue exitosa o falló.
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a la UI que la operación de carga ha finalizado,
                          // permitiendo ocultar el indicador de progreso o actualizar la vista.
    }
  }
}