import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:money_mind_mobile/data/models/user_model.dart';
import 'package:money_mind_mobile/features/auth/repositories/auth_repository.dart';
import 'package:crypto/crypto.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _currentUser;
  String? _authToken;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;
  String? _errorMessage;

  AuthProvider(this._authRepository) {
    print("🔍 [AuthProvider] Constructor llamado. Verificando sesión...");
    checkAuthStatus(); // ✅ Se mantiene la verificación inicial
  }

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  bool get isCheckingAuth => _isCheckingAuth;
  String? get errorMessage => _errorMessage;

  /// **Establece el mensaje de error y notifica a los listeners.**
  /// Esto es útil para centralizar la gestión de errores.
  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// **Restablece los estados de carga y error.**
  /// Útil cuando se navega a la pantalla de login para asegurar un estado limpio.
  void resetState() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
    print("🔄 [AuthProvider] Estados de carga y error reiniciados.");
  }

  // LOGIN
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _setErrorMessage(null); // Limpiamos el mensaje de error al inicio de un nuevo intento
    notifyListeners(); // Notificamos que la carga ha comenzado

    try {
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();

      final user = await _authRepository.login(email, hashedPassword);
      if (user != null) {
        _currentUser = user;
        _authToken = _authRepository.authToken;
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _authToken ?? '');
        await prefs.setString('authUser', jsonEncode(user.toJson()));

        print("✅ [AuthProvider] Inicio de sesión exitoso para ${user.correo}");
        return true; // Éxito en el login
      } else {
        _setErrorMessage('Credenciales inválidas. Por favor, inténtalo de nuevo.');
        print("⚠️ [AuthProvider] Login fallido: Credenciales inválidas.");
        return false; // Fallo en el login
      }
    } catch (e) {
      _setErrorMessage('Login fallido: ${e.toString()}');
      debugPrint('❌ [AuthProvider] Error en login: $e');
      return false; // Fallo en el login debido a una excepción
    } finally {
      // ✅ IMPORTANTE: Aseguramos que _isLoading siempre se restablezca a false
      _isLoading = false;
      notifyListeners(); // Notificamos que la carga ha terminado (sea éxito o error)
    }
  }

  // REGISTRO
  Future<bool> register(User user, String password) async {
    _isLoading = true;
    _setErrorMessage(null); // Limpiamos el mensaje de error al inicio de un nuevo intento
    notifyListeners(); // Notificamos que la carga ha comenzado

    try {
      final bytes = utf8.encode(password);
      final hashedPassword = sha256.convert(bytes).toString();

      final userWithHashedPassword = User(
        id: 0,
        nombre: user.nombre,
        correo: user.correo,
        contrasenaHash: hashedPassword,
        fechaRegistro: DateTime.now(),
      );

      final registeredUser = await _authRepository.register(userWithHashedPassword);
      if (registeredUser != null) {
        _currentUser = registeredUser;
        _authToken = _authRepository.authToken;
        _isLoggedIn = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', _authToken ?? '');
        await prefs.setString('authUser', jsonEncode(registeredUser.toJson()));

        print("✅ [AuthProvider] Registro exitoso para ${registeredUser.correo}");
        return true; // Éxito en el registro
      } else {
        _setErrorMessage('El registro falló. Por favor, inténtalo de nuevo.');
        print("⚠️ [AuthProvider] Registro fallido: Usuario no retornado.");
        return false; // Fallo en el registro
      }
    } catch (e) {
      _setErrorMessage('Registro fallido: ${e.toString()}');
      debugPrint('❌ [AuthProvider] Error en register: $e');
      return false; // Fallo en el registro debido a una excepción
    } finally {
      // ✅ IMPORTANTE: Aseguramos que _isLoading siempre se restablezca a false
      _isLoading = false;
      notifyListeners(); // Notificamos que la carga ha terminado (sea éxito o error)
    }
  }

  // LOGOUT
  Future<void> logout() async {
    _isLoading = true; // ✅ Activamos el indicador de carga para el logout
    _setErrorMessage(null); // Limpiamos mensajes de error previos
    notifyListeners(); // Notificamos que la carga de logout ha comenzado

    try {
      // Aquí puedes añadir cualquier lógica de limpieza adicional en el repositorio si es necesario
      // Por ejemplo, invalidar tokens en el servidor si tu backend lo soporta.
      // await _authRepository.logout(); // Si tienes un método de logout en tu repositorio.

      _authToken = null;
      _currentUser = null;
      _isLoggedIn = false;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('authToken');
      await prefs.remove('authUser');

      print("✅ [AuthProvider] Sesión cerrada exitosamente.");
    } catch (e) {
      _setErrorMessage('Error al cerrar sesión: ${e.toString()}');
      debugPrint('❌ [AuthProvider] Error en logout: $e');
    } finally {
      // ✅ IMPORTANTE: Aseguramos que _isLoading siempre se restablezca a false
      _isLoading = false;
      notifyListeners(); // Notificamos que la carga de logout ha terminado (sea éxito o error)
    }
  }

  // CHECK AUTH AL INICIO
  Future<void> checkAuthStatus() async {
    print("📡 [AuthProvider] Verificando autenticación en caché...");
    _isCheckingAuth = true;
    _setErrorMessage(null); // Limpiamos cualquier error previo
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      final userJson = prefs.getString('authUser');

      if (token != null && userJson != null) {
        print("✅ [AuthProvider] Token y usuario encontrados en caché.");
        _authToken = token;
        _authRepository.setAuthToken(token);
        _currentUser = User.fromJson(jsonDecode(userJson));
        _isLoggedIn = true;
      } else {
        print("⚠️ [AuthProvider] No hay token o usuario en caché.");
        _authToken = null;
        _currentUser = null;
        _isLoggedIn = false;
      }
    } catch (e) {
      _setErrorMessage('Error al verificar estado de autenticación: ${e.toString()}');
      debugPrint('❌ [AuthProvider] Error en checkAuthStatus: $e');
    } finally {
      _isCheckingAuth = false;
      print("🔔 [AuthProvider] Estado de autenticación verificado. Notificando listeners.");
      notifyListeners();
    }
  }
}