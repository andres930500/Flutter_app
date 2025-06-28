// lib/domain/usecases/get_recomendaciones_usecase.dart

import 'package:money_mind_mobile/data/models/recomendacion_model.dart'; // Importa el modelo de datos para las recomendaciones.
import 'package:money_mind_mobile/domain/repositories/recomendacion_repository.dart'; // Importa la interfaz del repositorio de recomendaciones.

/// **`GetRecomendacionesUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para la **obtención de recomendaciones ecológicas personalizadas para un usuario**.
///
/// Este patrón de diseño (Use Case) aísla la lógica específica de la operación
/// del resto de la aplicación, haciéndola más modular, mantenible y fácil de probar.
class GetRecomendacionesUseCase {
  /// Instancia del repositorio de recomendaciones.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para obtener la información de las recomendaciones.
  final RecomendacionRepository repository;

  /// Constructor de `GetRecomendacionesUseCase`.
  ///
  /// Recibe una implementación de `RecomendacionRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetRecomendacionesUseCase(this.repository);

  /// Método `execute` que lleva a cabo la operación de obtener las recomendaciones.
  ///
  /// Este método ahora se llama `execute` para mayor claridad y consistencia
  /// con un patrón más común para los Use Cases en la arquitectura limpia.
  ///
  /// Recibe el `usuarioId` del usuario para el que se desean recuperar las recomendaciones.
  /// Delega la llamada al método `getRecomendaciones` de la capa del repositorio.
  ///
  /// Retorna un `Future<List<Recomendacion>>` que contendrá una lista de objetos
  /// `Recomendacion` adaptadas al usuario proporcionado.
  Future<List<Recomendacion>> execute(int usuarioId) async {
    // Llama al método del repositorio para obtener la lista de recomendaciones.
    return await repository.getRecomendaciones(usuarioId);
  }
}