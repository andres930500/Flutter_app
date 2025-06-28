// user_model.dart

/// La clase `User` representa a un **usuario** en tu aplicación.
///
/// Este modelo define la estructura de los datos para un usuario,
/// incluyendo su **identificador único**, **nombre**, **correo electrónico**,
/// el **hash de su contraseña** y la **fecha en que se registró**.
/// Se corresponde con la entidad `Usuario.cs` que tendrías en un backend C#.
class User {
  /// El **identificador único** del usuario.
  final int id;

  /// El **nombre** del usuario.
  final String nombre;

  /// La dirección de **correo electrónico** del usuario, usada para el inicio de sesión.
  final String correo;

  /// El **hash de la contraseña** del usuario, almacenado de forma segura (nunca la contraseña en texto plano).
  final String contrasenaHash;

  /// La **fecha y hora de registro** del usuario en la aplicación.
  final DateTime fechaRegistro;

  /// Constructor de la clase `User`.
  ///
  /// Requiere que proporciones todos los campos (`id`, `nombre`, `correo`,
  /// `contrasenaHash`, `fechaRegistro`) al crear una instancia de `User`.
  User({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.contrasenaHash,
    required this.fechaRegistro,
  });

  /// **Constructor `factory` `fromJson`** para crear una instancia de `User`
  /// a partir de un mapa JSON.
  ///
  /// Úsalo cuando recibas datos de usuario de una API.
  /// Toma un `Map<String, dynamic>` (la representación JSON)
  /// y mapea sus claves a las propiedades correspondientes de la clase `User`.
  /// La cadena `fechaRegistro` se convierte a un objeto `DateTime`.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      contrasenaHash: json['contrasenaHash'],
      fechaRegistro: DateTime.parse(json['fechaRegistro']), // Convierte la cadena de fecha a DateTime.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `User` a un mapa JSON.
  ///
  /// Este método es útil para serializar un objeto `User` a un formato JSON,
  /// por ejemplo, para enviar datos de registro o actualización de perfil a un backend.
  /// La fecha de registro se serializa a una cadena en formato `ISO 8601` completo.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'contrasenaHash': contrasenaHash,
      'fechaRegistro': fechaRegistro.toIso8601String(), // Convierte DateTime a cadena ISO 8601 para JSON.
    };
  }
}