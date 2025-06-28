import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.
import 'package:money_mind_mobile/data/models/recomendacion_model.dart'; // Importa el modelo de Recomendación Ecológica.
import 'package:money_mind_mobile/domain/repositories/recomendacion_repository.dart'; // Importa la interfaz del repositorio de recomendaciones.

/// Implementación concreta de `RecomendacionRepository` que interactúa con un servicio API.
///
/// Esta clase es responsable de obtener las recomendaciones ecológicas de un usuario,
/// actuando como un puente entre la lógica de negocio de la aplicación y la fuente de datos
/// remota (en este caso, una API RESTful a través de `ApiService`).
class RecomendacionRepositoryImpl implements RecomendacionRepository {
  /// Instancia de `ApiService` utilizada para realizar llamadas al backend.
  /// Se inicializa directamente aquí con una instancia por defecto.
  final ApiService _apiService = ApiService();

  /// Obtiene una lista de recomendaciones ecológicas para un usuario específico.
  ///
  /// Delega la llamada al método `getRecomendacionesEcologicas` del `_apiService`.
  @override
  Future<List<Recomendacion>> getRecomendaciones(int usuarioId) {
    return _apiService.getRecomendacionesEcologicas(usuarioId);
  }
}