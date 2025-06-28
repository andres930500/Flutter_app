import 'package:money_mind_mobile/data/models/user_model.dart'; // Importa el modelo de usuario para poder relacionar un presupuesto con un usuario.

/// Clase `Budget` que representa un presupuesto en la aplicación.
///
/// Este modelo define la estructura de los datos para un presupuesto,
/// incluyendo su identificador, el ID del usuario al que pertenece,
/// el nombre del presupuesto, el monto asignado, las fechas de inicio y fin,
/// y opcionalmente, el objeto `User` completo al que está asociado.
class Budget {
  /// El identificador único del presupuesto.
  final int id;

  /// El ID del usuario al que pertenece este presupuesto.
  final int usuarioId;

  /// El nombre descriptivo del presupuesto (ej. "Presupuesto de Noviembre").
  final String nombre;

  /// El monto total asignado a este presupuesto.
  final double monto;

  /// La fecha de inicio del período que abarca el presupuesto.
  final DateTime fechaInicio;

  /// La fecha de finalización del período que abarca el presupuesto.
  final DateTime fechaFin;

  /// El objeto `User` completo asociado a este presupuesto. Es `nullable` (puede ser nulo)
  /// porque no siempre es necesario cargar los datos completos del usuario
  /// cuando se obtiene un presupuesto del backend, o el backend podría no enviarlo.
  final User? usuario;

  /// Constructor de la clase `Budget`.
  ///
  /// Requiere los valores para `id`, `usuarioId`, `nombre`, `monto`,
  /// `fechaInicio` y `fechaFin`. El campo `usuario` es opcional,
  /// lo que permite crear instancias de `Budget` sin necesidad de tener el objeto `User` completo.
  Budget({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.monto,
    required this.fechaInicio,
    required this.fechaFin,
    this.usuario, // El campo `usuario` ya no es obligatorio en el constructor.
  });

  /// Factory constructor `fromJson` para crear una instancia de `Budget` desde un mapa JSON.
  ///
  /// Se utiliza al recibir datos de la API. Realiza el parseo de los tipos de datos
  /// y maneja la conversión de las cadenas de fecha a objetos `DateTime`.
  /// También gestiona la creación de un objeto `User` anidado si la clave 'usuario'
  /// está presente y no es nula en el JSON de respuesta del backend.
  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'],
      usuarioId: json['usuarioId'],
      nombre: json['nombre'],
      monto: (json['monto'] as num).toDouble(), // Asegura que el monto sea un `double`.
      fechaInicio: DateTime.parse(json['fechaInicio']), // Convierte la cadena de fecha a `DateTime`.
      fechaFin: DateTime.parse(json['fechaFin']), // Convierte la cadena de fecha a `DateTime`.
      // Si 'usuario' no es nulo en el JSON, se parsea a un objeto `User`, de lo contrario, es nulo.
      usuario: json['usuario'] != null ? User.fromJson(json['usuario']) : null,
    );
  }

  /// Método `toJson` para convertir una instancia de `Budget` a un mapa JSON.
  ///
  /// Este método es utilizado para enviar datos de `Budget` al backend,
  /// por ejemplo, al crear o actualizar un presupuesto.
  /// Incluye el `id` (importante para actualizaciones `PUT`), el `usuarioId`,
  /// el `nombre`, el `monto`, y las fechas `fechaInicio` y `fechaFin`
  /// formateadas a `ISO 8601` y truncadas para obtener solo la parte de la fecha (YYYY-MM-DD).
  ///
  /// **Nota importante:** Se incluye solo el `usuarioId` y no el objeto `usuario` completo,
  /// ya que el backend típicamente espera solo el ID de la relación, no el objeto anidado.
  Map<String, dynamic> toJson() {
    return {
      // El 'id' se incluye aquí porque este método `toJson` puede ser reutilizado
      // para peticiones de actualización (PUT), donde el ID es necesario.
      // Para peticiones de creación (POST), la lógica en `ApiService`
      // debería omitir este campo si el backend lo autogenera.
      "id": id,
      "usuarioId": usuarioId, // Se envía solo el ID del usuario, no el objeto completo.
      "nombre": nombre,
      "monto": monto,
      // Formatea las fechas a "YYYY-MM-DD" para que sean compatibles con el backend.
      "fechaInicio": fechaInicio.toIso8601String().split('T')[0],
      "fechaFin": fechaFin.toIso8601String().split('T')[0],
      // No se incluye "usuario" aquí, ya que el backend espera el `usuarioId` en su lugar.
    };
  }
}