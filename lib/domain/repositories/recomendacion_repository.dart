import 'package:money_mind_mobile/data/models/recomendacion_model.dart'; // Importa el modelo de datos para las recomendaciones ecológicas.

/// `RecomendacionRepository` es una **interfaz abstracta** que define el contrato
/// para las operaciones relacionadas con la obtención de recomendaciones ecológicas.
///
/// Esta interfaz especifica qué funcionalidades deben estar disponibles para
/// acceder a los datos de las recomendaciones, sin preocuparse por los detalles
/// de cómo se implementan (por ejemplo, si los datos provienen de una API
/// o una base de datos local). Esto fomenta una arquitectura limpia y la
/// separación de responsabilidades en tu aplicación.
abstract class RecomendacionRepository {
  /// Obtiene una lista de todas las recomendaciones ecológicas disponibles para un `usuarioId` específico.
  ///
  /// Retorna un `Future` que resuelve en una `List` de objetos `Recomendacion`.
  Future<List<Recomendacion>> getRecomendaciones(int usuarioId);
}