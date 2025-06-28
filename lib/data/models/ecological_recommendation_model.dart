// ecological_recommendation_model.dart

/// La clase `EcologicalRecommendation` representa una **recomendación ecológica**
/// generada para un usuario, que puede estar o no vinculada a un gasto específico.
///
/// Este modelo refleja la estructura de una entidad `RecomendacionEcologica`
/// en tu backend. Contiene detalles esenciales como el identificador de la recomendación,
/// el usuario al que va dirigida, un posible gasto asociado, el texto de la recomendación
/// y la fecha en que fue generada.
class EcologicalRecommendation {
  /// El **identificador único** de la recomendación ecológica.
  final int id;

  /// El **ID del usuario** al que se dirige esta recomendación.
  final int usuarioId;

  /// El **ID del gasto** al que esta recomendación está asociada, si existe.
  /// Puede ser `null` si la recomendación no está ligada a un gasto específico.
  final int? gastoId;

  /// El **texto** con el contenido de la recomendación ecológica.
  final String texto;

  /// La **fecha y hora** en que se generó esta recomendación.
  final DateTime fechaGeneracion;

  /// Constructor de la clase `EcologicalRecommendation`.
  ///
  /// Requiere que proporciones el `id`, `usuarioId`, `texto` y `fechaGeneracion`.
  /// El campo `gastoId` es opcional y puede ser nulo.
  EcologicalRecommendation({
    required this.id,
    required this.usuarioId,
    this.gastoId,
    required this.texto,
    required this.fechaGeneracion,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `EcologicalRecommendation`
  /// a partir de un mapa JSON.
  ///
  /// Utilízalo cuando recibas datos de recomendaciones de tu API. Extrae los valores
  /// de las claves JSON correspondientes y convierte la cadena `fechaGeneracion`
  /// en un objeto `DateTime`. Maneja `gastoId` como un campo opcional que puede ser nulo.
  factory EcologicalRecommendation.fromJson(Map<String, dynamic> json) {
    return EcologicalRecommendation(
      id: json['id'],
      usuarioId: json['usuarioId'],
      gastoId: json['gastoId'], // Será `null` si no está presente en el JSON.
      texto: json['texto'],
      fechaGeneracion: DateTime.parse(json['fechaGeneracion']), // Parsea la cadena de fecha.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `EcologicalRecommendation` a un mapa JSON.
  ///
  /// Este método es útil para serializar el objeto y enviarlo a tu backend,
  /// por ejemplo, si necesitaras registrar una recomendación desde el lado del cliente
  /// o para propósitos de depuración. Las fechas se serializan a una cadena
  /// en formato `ISO 8601` completo.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'gastoId': gastoId,
      'texto': texto,
      'fechaGeneracion': fechaGeneracion.toIso8601String(), // Serializa la fecha completa.
    };
  }
}