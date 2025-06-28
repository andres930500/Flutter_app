import 'package:money_mind_mobile/data/models/user_model.dart'; // Importa el modelo de usuario para establecer la relación.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de presupuesto para establecer la relación.
import 'package:money_mind_mobile/data/models/category_model.dart'; // Importa el modelo de categoría. Asegúrate de que el nombre del archivo y la clase sean correctos.

/// Clase `Income` que representa un ingreso registrado por un usuario en la aplicación.
///
/// Este modelo define la estructura de los datos para un ingreso individual,
/// incluyendo su identificador único, el ID del usuario que lo registró,
/// el ID del presupuesto asociado (si lo hay), el ID de la categoría (si lo hay),
/// una descripción, el monto del ingreso y la fecha en que se recibió.
///
/// Además, incluye propiedades para los objetos de navegación (`User`, `Budget`, `Category`)
/// que pueden ser poblados si el backend los incluye en la respuesta.
class Income {
  /// El identificador único del ingreso.
  final int id;

  /// El ID del usuario que registró este ingreso.
  final int usuarioId;

  /// El ID del presupuesto al que este ingreso está vinculado.
  /// Puede ser `null` si el ingreso no está asignado a un presupuesto específico.
  final int? presupuestoId;

  /// El ID de la categoría a la que pertenece este ingreso (ej. "Salario", "Regalo").
  /// Puede ser `null` si la categoría es opcional o no está asignada.
  final int? categoriaId;

  /// Una descripción breve del ingreso.
  final String descripcion;

  /// El monto monetario del ingreso.
  final double monto;

  /// La fecha en que se recibió el ingreso.
  final DateTime fecha;

  // --- NUEVAS PROPIEDADES DE NAVEGACIÓN ---
  /// El objeto `User` completo asociado a este ingreso.
  /// Será `null` si el backend no lo incluye o si no es relevante.
  final User? usuario;

  /// El objeto `Budget` completo asociado a este ingreso.
  /// Será `null` si el backend no lo incluye o si el `presupuestoId` es nulo.
  final Budget? presupuesto;

  /// El objeto `Category` completo asociado a este ingreso.
  /// Será `null` si el backend no lo incluye o si el `categoriaId` es nulo.
  final Category? categoria;

  /// Constructor de la clase `Income`.
  ///
  /// Requiere que se proporcionen `id`, `usuarioId`, `descripcion`, `monto` y `fecha`.
  /// `presupuestoId` y `categoriaId` son opcionales y pueden ser nulos.
  /// Las propiedades de navegación (`usuario`, `presupuesto`, `categoria`) también son opcionales.
  Income({
    required this.id,
    required this.usuarioId,
    this.presupuestoId,
    this.categoriaId,
    required this.descripcion,
    required this.monto,
    required this.fecha,
    this.usuario, // Ahora se acepta el objeto User.
    this.presupuesto, // Ahora se acepta el objeto Budget.
    this.categoria, // Ahora se acepta el objeto Category.
  });

  /// Factory constructor `fromJson` para crear una instancia de `Income` desde un mapa JSON.
  ///
  /// Se utiliza cuando se reciben datos de ingresos de una API.
  /// Toma un `Map<String, dynamic>` (la representación JSON)
  /// y mapea sus claves a las propiedades de la clase `Income`.
  /// Realiza la conversión de `monto` a `double` y parsea la cadena de `fecha` a un `DateTime`.
  ///
  /// **Manejo de objetos anidados:**
  /// Incluye lógicas para parsear los objetos `User`, `Budget` y `Category` si están
  /// presentes en el JSON de respuesta y no son nulos. Esto permite deserializar
  /// relaciones de datos enviadas por el backend.
  factory Income.fromJson(Map<String, dynamic> json) {
    return Income(
      id: json['id'],
      usuarioId: json['usuarioId'],
      presupuestoId: json['presupuestoId'], // Será `null` si no está presente o es nulo en el JSON.
      categoriaId: json['categoriaId'], // Será `null` si no está presente o es nulo en el JSON.
      descripcion: json['descripcion'],
      monto: (json['monto'] as num).toDouble(), // Convierte cualquier tipo numérico a double.
      fecha: DateTime.parse(json['fecha']), // Parsea la cadena ISO 8601 a DateTime.
      // NUEVAS LÓGICAS PARA PARSEAR OBJETOS ANIDADOS:
      // Si el JSON contiene la clave 'usuario' y su valor no es nulo, se crea una instancia de User.
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
      // Si el JSON contiene la clave 'presupuesto' y su valor no es nulo, se crea una instancia de Budget.
      presupuesto: json['presupuesto'] != null ? Budget.fromJson(json['presupuesto']) : null,
      // Si el JSON contiene la clave 'categoria' y su valor no es nulo, se crea una instancia de Category.
      // Es importante notar que el nombre de la clave en el JSON ('categoria' en minúsculas)
      // debe coincidir con el del modelo, incluso si el nombre de la clase en C# es diferente (ej. 'Categorium').
      categoria: json['categoria'] != null ? Category.fromJson(json['categoria']) : null,
    );
  }

  /// Método `toJson` para convertir una instancia de `Income` a un mapa JSON.
  ///
  /// Este método es útil para serializar el objeto `Income` completo,
  /// por ejemplo, para almacenamiento local o para enviar datos a otro servicio.
  /// La fecha se convierte a una cadena en formato ISO 8601 completa.
  ///
  /// **NOTA IMPORTANTE:**
  /// En el contexto de este proyecto, el `ApiService` utiliza un método interno (`_incomeToJsonDto`)
  /// para serializar los datos de `Income` que se enviarán al backend en operaciones de POST y PUT.
  /// Ese método interno selecciona específicamente solo los campos escalares y los IDs (`usuarioId`,
  /// `presupuestoId`, `categoriaId`) que el backend espera en un DTO (Data Transfer Object)
  /// para la creación o actualización de un ingreso, *sin incluir los objetos de navegación completos*.
  ///
  /// Por lo tanto, este método `toJson()` de la clase `Income` es más genérico y podría usarse
  /// para otros propósitos dentro de la aplicación Flutter (como depuración, logging,
  /// o si un futuro endpoint de la API esperara el objeto completo), pero *no es el que se usa
  /// directamente* para interactuar con los endpoints de creación/actualización de ingresos
  /// definidos en `ApiService`.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'presupuestoId': presupuestoId,
      'categoriaId': categoriaId,
      'descripcion': descripcion,
      'monto': monto,
      'fecha': fecha.toIso8601String(), // Convierte DateTime a cadena ISO 8601 para JSON.
      // Opcional: Se pueden incluir los objetos anidados si se necesita serializar el modelo completo
      // para otros usos, no para las operaciones POST/PUT de la API actual.
      'usuario': usuario?.toJson(),
      'presupuesto': presupuesto?.toJson(),
      'categoria': categoria?.toJson(),
    };
  }
}