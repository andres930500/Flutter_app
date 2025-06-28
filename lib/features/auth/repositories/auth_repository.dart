import 'package:money_mind_mobile/data/models/user_model.dart'; // Importa el modelo de datos para el usuario.
import 'package:money_mind_mobile/api/services/api_service.dart'; // Importa el servicio API para interactuar con el backend.

/// **`AuthRepository`** es una clase que actúa como un intermediario entre
/// los casos de uso (o la capa de dominio) y la fuente de datos (en este caso, `ApiService`)
/// para todas las operaciones relacionadas con la **autenticación de usuarios**.
///
/// Su responsabilidad principal es abstraer los detalles de la comunicación
/// con la API, proporcionando una interfaz limpia para que la lógica de negocio
/// realice operaciones de login y registro.
class AuthRepository {
  /// Instancia del `ApiService` que se utiliza para realizar las llamadas HTTP
  /// al backend. Es una dependencia inyectada en el constructor.
  final ApiService _apiService;

  /// Constructor de `AuthRepository`.
  ///
  /// Recibe una instancia de `ApiService` a través de la inyección de dependencias,
  /// lo que facilita la prueba y el manejo de diferentes implementaciones de la API.
  AuthRepository(this._apiService);

  /// Intenta **iniciar sesión** con el correo electrónico y la contraseña hasheada.
  ///
  /// Delega la llamada al método `login` del `_apiService`. Se espera que la
  /// contraseña ya esté hasheada antes de ser pasada a este método por razones de seguridad.
  ///
  /// Retorna un `Future<User?>`:
  /// - Un objeto `User` si las credenciales son válidas y el login es exitoso.
  /// - `null` si las credenciales son inválidas o si ocurre un error en la API.
  Future<User?> login(String email, String hashedPassword) {
    return _apiService.login(email, hashedPassword);
  }

  /// Intenta **registrar un nuevo usuario** en el sistema.
  ///
  /// Recibe un objeto `User` que ya debe contener la contraseña hasheada en su campo
  /// `contrasenaHash`. Este método delega la operación al `_apiService`.
  ///
  /// Retorna un `Future<User?>`:
  /// - El objeto `User` recién registrado (posiblemente con un ID asignado por el backend)
  ///   si el registro es exitoso.
  /// - `null` si el registro falla (ej., correo ya registrado, error del servidor).
  Future<User?> register(User user) {
    return _apiService.registerUser(user);
  }

  /// Obtiene el token de autenticación actual almacenado en el `ApiService`.
  ///
  /// Este getter permite a las capas superiores acceder al token JWT (o similar)
  /// que fue obtenido durante el proceso de login.
  String? get authToken => _apiService.authToken;

  /// Establece el token de autenticación en el `ApiService`.
  ///
  /// Este método es útil para restaurar el token de una sesión guardada (ej., desde `SharedPreferences`)
  /// para que `ApiService` pueda incluirlo en futuras solicitudes API.
  void setAuthToken(String token) {
    _apiService.setAuthToken(token);
  }
}