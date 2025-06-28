// lib/api/services/api_service.dart

import 'dart:convert'; // Para codificar y decodificar JSON.
import 'package:flutter/foundation.dart'; // Para utilidades de depuración como `debugPrint`.
import 'package:money_mind_mobile/utils/constants.dart'; // Constantes de la aplicación, como la URL base de la API.
import 'package:dio/dio.dart'; // Paquete para realizar solicitudes HTTP avanzadas.

// Importación de los modelos de datos.
import 'package:money_mind_mobile/data/models/user_model.dart';
import 'package:money_mind_mobile/data/models/budget_model.dart';
import 'package:money_mind_mobile/data/models/expense_model.dart';
import 'package:money_mind_mobile/data/models/income_model.dart';
import 'package:money_mind_mobile/data/models/category_model.dart' as model; // Se alias para evitar conflicto con 'Category' de otros paquetes.
import 'package:money_mind_mobile/data/models/report_model.dart'; // Aunque importado, no se usa en el código proporcionado.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart';
import 'package:money_mind_mobile/data/models/category_total.dart';
import 'package:money_mind_mobile/data/models/recomendacion_model.dart';

/// `ApiService` es una clase Singleton que gestiona todas las interacciones con la API.
/// Proporciona métodos para autenticación, gestión de ingresos, gastos, categorías y presupuestos,
/// así como la obtención de datos para el dashboard y recomendaciones.
class ApiService {
  /// Token de autenticación del usuario, si está logueado.
  String? _authToken;

  /// Instancia de `Dio` para realizar solicitudes HTTP.
  final Dio _dio;

  /// Constructor privado para el patrón Singleton.
  /// Inicializa `_dio`. Si no se proporciona, se usa una instancia por defecto.
  ApiService._internal({Dio? dio})
      : _dio = dio ?? Dio();

  /// Instancia estática única de `ApiService` (Singleton).
  static final ApiService _instance = ApiService._internal();

  /// Factory constructor para obtener la instancia única de `ApiService`.
  /// Permite acceder a la clase como `ApiService()`.
  factory ApiService() => _instance;

  /// Getter para el token de autenticación.
  String? get authToken => _authToken;

  /// Establece el token de autenticación.
  /// Imprime el token actualizado para depuración.
  void setAuthToken(String? token) {
    _authToken = token;
    debugPrint('Auth token updated: $_authToken');
  }

  /// Construye un objeto `Options` para `Dio` con cabeceras HTTP.
  /// Incluye el `Content-Type` por defecto como `application/json`
  /// y añade el token de autorización si está presente.
  Options _getDioOptions({String contentType = 'application/json'}) {
    final headers = <String, dynamic>{'Content-Type': contentType};
    if (_authToken != null) headers['Authorization'] = 'Bearer $_authToken';
    return Options(headers: headers);
  }

  // --- Métodos de Autenticación ---

  /// Intenta iniciar sesión con el correo electrónico y la contraseña hash proporcionados.
  ///
  /// Realiza una solicitud GET a la API de usuarios y busca una coincidencia.
  /// Si se encuentra un usuario, establece un token de autenticación "falso" y lo devuelve.
  /// Lanza una excepción si hay un error al obtener los usuarios.
  Future<User?> login(String email, String hashedPassword) async {
    final url = '${ApiConstants.baseUrl}/api/UsuariosAPI';
    try {
      final response = await _dio.get(url, options: _getDioOptions());

      if (response.statusCode != 200) {
        debugPrint('Error al obtener usuarios para login: ${response.statusCode}');
        debugPrint('Cuerpo de la respuesta de error (Login): ${response.data}');
        throw Exception('Error al obtener usuarios para login: ${response.statusCode}');
      }

      final List<dynamic> lista = response.data; // Dio ya decodifica JSON
      for (var u in lista) {
        final user = User.fromJson(u);
        if (user.correo.trim().toLowerCase() == email.trim().toLowerCase() &&
            user.contrasenaHash == hashedPassword) {
          setAuthToken('fake-token-${user.id}'); // Token de autenticación de ejemplo.
          return user;
        }
      }
      return null; // Si no se encuentra ninguna coincidencia de usuario.
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error en ApiService.login: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error de red o servidor al iniciar sesión: ${e.message}');
    } catch (e) {
      debugPrint('🚨 Error inesperado en ApiService.login: $e');
      throw Exception('Error inesperado al iniciar sesión: $e');
    }
  }

  /// Registra un nuevo usuario en la API.
  ///
  /// Envía los datos del usuario como JSON en una solicitud POST.
  /// Devuelve el usuario creado si el registro es exitoso (código 201), de lo contrario, `null`.
  Future<User?> registerUser(User user) async {
    debugPrint('Enviando usuario a la API: ${user.toJson()}');
    final url = '${ApiConstants.baseUrl}/api/UsuariosAPI';

    try {
      final res = await _dio.post(
        url,
        options: _getDioOptions(),
        data: user.toJson(), // Dio envía el mapa directamente como JSON
      );

      if (res.statusCode == 201) {
        return User.fromJson(res.data);
      } else {
        debugPrint('Error al registrar usuario: ${res.statusCode}');
        debugPrint('Cuerpo de la respuesta de error: ${res.data}');
        return null;
      }
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error en ApiService.registerUser: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('🚨 Error inesperado en ApiService.registerUser: $e');
      return null;
    }
  }

  // --- Métodos de Ingresos ---

  /// Convierte un objeto `Income` a un mapa JSON compatible con la API de ingresos.
  /// Formatea la fecha a `yyyy-MM-dd`.
  Map<String, dynamic> _incomeToJsonDto(Income income) {
    return {
      "usuarioId": income.usuarioId,
      "presupuestoId": income.presupuestoId,
      "categoriaId": income.categoriaId,
      "descripcion": income.descripcion,
      "monto": income.monto,
      "fecha": income.fecha.toIso8601String().split("T")[0],
    };
  }

  /// Crea un nuevo ingreso en la API.
  ///
  /// Envía los datos del ingreso como JSON en una solicitud POST.
  /// Imprime logs de depuración para la URL, cabeceras, cuerpo enviado y respuesta.
  /// Retorna `true` si la creación es exitosa (códigos 201 o 200), de lo contrario `false`.
  Future<bool> createIncome(Income income) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi';
    final data = _incomeToJsonDto(income);

    debugPrint('🌐 ApiService - POST $url');
    debugPrint('📦 Body: $data');

    try {
      final response = await _dio.post(url, options: _getDioOptions(), data: data);
      debugPrint('🔁 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error en ApiService.createIncome: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('🚨 Error en ApiService.createIncome: $e');
      return false;
    }
  }

  /// Obtiene una lista de todos los ingresos de la API.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a una lista de objetos `Income`.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<Income>> getIncomes() async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => Income.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error al obtener ingresos: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener ingresos: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Error inesperado al obtener ingresos: $e');
      throw Exception('Error inesperado al obtener ingresos: $e');
    }
  }

  /// Obtiene un ingreso específico por su ID.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a un objeto `Income`.
  /// Retorna `null` si el ingreso no se encuentra (código 404).
  /// Lanza una excepción para otros errores.
  Future<Income?> getIncomeById(int id) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/$id';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return Income.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Ingreso no encontrado: ${e.response?.data}');
        return null;
      }
      debugPrint('🚨 Dio Error al obtener ingreso por ID: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener ingreso por ID: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Error inesperado al obtener ingreso por ID: $e');
      throw Exception('Error inesperado al obtener ingreso por ID: $e');
    }
  }

  /// Actualiza un ingreso existente en la API.
  ///
  /// Envía los datos del ingreso actualizado como JSON en una solicitud PUT.
  /// Imprime logs de depuración del proceso.
  /// Retorna `true` si la actualización es exitosa (código 204), de lo contrario `false`.
  Future<bool> updateIncome(Income income) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/${income.id}';
    final data = {
      "id": income.id,
      "usuarioId": income.usuarioId,
      "presupuestoId": income.presupuestoId,
      "categoriaId": income.categoriaId,
      "descripcion": income.descripcion,
      "monto": income.monto,
      "fecha": income.fecha.toIso8601String().split("T")[0],
    };

    debugPrint('🔄 Actualizando ingreso...');
    debugPrint('📤 URL: $url');
    debugPrint('🧾 Body enviado: $data');

    try {
      final response = await _dio.put(url, options: _getDioOptions(), data: data);
      debugPrint('📨 Código de respuesta: ${response.statusCode}');
      debugPrint('📩 Respuesta del servidor: ${response.data}');
      return response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al actualizar ingreso: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar ingreso: $e');
      return false;
    }
  }

  /// Elimina un ingreso por su ID.
  ///
  /// Realiza una solicitud DELETE.
  /// Retorna `true` si la eliminación es exitosa (código 204), de lo contrario `false`.
  Future<bool> deleteIncome(int id) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/$id';
    try {
      final response = await _dio.delete(url, options: _getDioOptions());
      if (response.statusCode == 204) {
        debugPrint('✅ Ingreso eliminado exitosamente. ID: $id');
        return true;
      } else {
        debugPrint('❌ Error al eliminar ingreso. Status: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al eliminar ingreso: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar ingreso: $e');
      return false;
    }
  }

  /// Obtiene los ingresos agrupados por mes para un presupuesto específico.
  ///
  /// Retorna una lista de `MonthlyData` o una lista vacía si hay un error.
  Future<List<MonthlyData>> getIngresosPorPresupuesto(int presupuestoId) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/por-presupuesto/$presupuestoId';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return (response.data as List).map((e) => MonthlyData.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener ingresos por presupuesto: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener ingresos por presupuesto: $e');
      return [];
    }
  }

  /// Obtiene todos los ingresos asociados a un usuario específico.
  ///
  /// Este método es crucial para mostrar el historial de ingresos de un usuario.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<Income>> getIncomesByUser(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/usuario/$usuarioId';
    debugPrint('🌐 ApiService - GET Ingresos por Usuario: $url');
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      debugPrint('🔁 Status: ${response.statusCode}');
      debugPrint('📨 Body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Income.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar ingresos por usuario: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🚨 Dio Excepción al obtener ingresos por usuario: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al cargar ingresos por usuario: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Excepción inesperada al obtener ingresos por usuario: $e');
      throw Exception('Excepción inesperada al obtener ingresos por usuario: $e');
    }
  }

  // --- Métodos de Gastos ---

  /// Obtiene un gasto específico por su ID.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a un objeto `Expense`.
  /// Retorna `null` si el gasto no se encuentra (código 404).
  /// Lanza una excepción para otros errores.
  Future<Expense?> getExpenseById(int id) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/$id';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return Expense.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Gasto no encontrado: ${e.response?.data}');
        return null;
      }
      debugPrint('🚨 Dio Error al obtener gasto por ID: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener gasto por ID: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Error inesperado al obtener gasto por ID: $e');
      throw Exception('Error inesperado al obtener gasto por ID: $e');
    }
  }

  /// Actualiza un gasto existente en la API.
  ///
  /// Envía los datos del gasto actualizado como JSON en una solicitud PUT.
  /// Imprime logs de depuración del proceso.
  /// Retorna `true` si la actualización es exitosa (código 204), de lo contrario `false`.
  Future<bool> updateExpense(Expense expense) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/${expense.id}';
    final data = {
      "id": expense.id,
      "usuarioId": expense.usuarioId,
      "presupuestoId": expense.presupuestoId,
      "categoriaId": expense.categoriaId,
      "descripcion": expense.descripcion,
      "monto": expense.monto,
      "fecha": expense.fecha.toIso8601String().split("T")[0],
    };

    debugPrint('🔄 Actualizando gasto...');
    debugPrint('📤 URL: $url');
    debugPrint('🧾 Body enviado: $data');

    try {
      final response = await _dio.put(url, options: _getDioOptions(), data: data);
      debugPrint('📨 Código de respuesta: ${response.statusCode}');
      debugPrint('📩 Respuesta del servidor: ${response.data}');
      return response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al actualizar gasto: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar gasto: $e');
      return false;
    }
  }

  /// Elimina un gasto por su ID.
  ///
  /// Realiza una solicitud DELETE.
  /// Retorna `true` si la eliminación es exitosa (código 204), de lo contrario `false`.
  Future<bool> deleteExpense(int id) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/$id';
    try {
      final response = await _dio.delete(url, options: _getDioOptions());
      if (response.statusCode == 204) {
        debugPrint('✅ Gasto eliminado exitosamente. ID: $id');
        return true;
      } else {
        debugPrint('❌ Error al eliminar gasto. Status: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al eliminar gasto: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado al eliminar gasto: $e');
      return false;
    }
  }
  
  /// Convierte un objeto `Expense` a un mapa JSON compatible con la API de gastos.
  /// Formatea la fecha a `yyyy-MM-dd`.
  Map<String, dynamic> _expenseToJsonDto(Expense expense) {
    return {
      "usuarioId": expense.usuarioId,
      "presupuestoId": expense.presupuestoId,
      "categoriaId": expense.categoriaId,
      "descripcion": expense.descripcion,
      "monto": expense.monto,
      "fecha": expense.fecha.toIso8601String().split("T")[0],
    };
  }

  /// Crea un nuevo gasto en la API.
  ///
  /// Envía los datos del gasto como JSON en una solicitud POST.
  /// Imprime logs de depuración.
  /// Retorna `true` si la creación es exitosa (códigos 201 o 200), de lo contrario `false`.
  Future<bool> postExpense(Expense expense) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi';
    final data = _expenseToJsonDto(expense);

    debugPrint('🌐 ApiService - POST Gasto: $url');
    debugPrint('📦 Body: $data');

    try {
      final response = await _dio.post(url, options: _getDioOptions(), data: data);
      debugPrint('🔁 Status: ${response.statusCode}');
      debugPrint('📨 Body: ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error al crear gasto: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('🚨 Error inesperado al crear gasto: $e');
      return false;
    }
  }

  /// Obtiene una lista de todos los gastos de la API.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a una lista de objetos `Expense`.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<Expense>> getExpenses() async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi';
    debugPrint('🌐 GET gastos: $url');
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      debugPrint('📨 Status: ${response.statusCode}');
      debugPrint('📨 Body: ${response.data}');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Expense.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar gastos: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🚨 Dio Excepción al obtener gastos: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener gastos: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Excepción inesperada al obtener gastos: $e');
      throw Exception('Excepción inesperada al obtener gastos: $e');
    }
  }

  /// Obtiene todos los gastos asociados a un usuario específico.
  ///
  /// Este método es necesario para mostrar el historial de gastos de un usuario.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<Expense>> getExpensesByUser(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/usuario/$usuarioId';
    debugPrint('🌐 ApiService - GET Gastos por Usuario: $url');
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      debugPrint('🔁 Status: ${response.statusCode}');
      debugPrint('📨 Body: ${response.data}');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Expense.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar gastos por usuario: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('🚨 Dio Excepción al obtener gastos por usuario: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al cargar gastos por usuario: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('🚨 Excepción inesperada al obtener gastos por usuario: $e');
      throw Exception('Excepción inesperada al obtener gastos por usuario: $e');
    }
  }

  /// Obtiene los gastos agrupados por mes para un presupuesto específico.
  ///
  /// Retorna una lista de `MonthlyData` o una lista vacía si hay un error.
  Future<List<MonthlyData>> getGastosPorPresupuesto(int presupuestoId) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/por-presupuesto/$presupuestoId';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return (response.data as List).map((e) => MonthlyData.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener gastos por presupuesto: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener gastos por presupuesto: $e');
      return [];
    }
  }

  // --- Métodos de Categorías ---

  /// Obtiene una lista de todas las categorías de la API.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a una lista de objetos `model.Category`.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<model.Category>> getCategories() async {
    final url = '${ApiConstants.baseUrl}/api/CategoriaApi';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => model.Category.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('Error al cargar categorías: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al cargar categorías: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error inesperado al cargar categorías: $e');
      throw Exception('Error inesperado al cargar categorías: $e');
    }
  }

  /// Obtiene una categoría específica por su ID.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a un objeto `model.Category`.
  /// Retorna `null` si la categoría no se encuentra (código 404).
  /// Lanza una excepción para otros errores.
  Future<model.Category?> getCategoryById(int id) async {
    final url = '${ApiConstants.baseUrl}/api/CategoriaApi/$id';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return model.Category.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Categoría no encontrada: ${e.response?.data}');
        return null;
      }
      debugPrint('Error al obtener categoría por ID: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener categoría por ID: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error inesperado al obtener categoría por ID: $e');
      throw Exception('Error inesperado al obtener categoría por ID: $e');
    }
  }

  /// Crea una nueva categoría en la API.
  ///
  /// Envía los datos de la categoría como JSON en una solicitud POST.
  /// Imprime logs de depuración detallados, incluyendo el cuerpo de la respuesta de error si no es exitosa.
  /// Retorna `true` si la creación es exitosa (código 201), de lo contrario `false`.
  Future<bool> createCategory(model.Category category) async {
    final url = '${ApiConstants.baseUrl}/api/CategoriaApi';
    debugPrint("🧾 Enviando categoría: ${category.toJson()}");
    try {
      final response = await _dio.post(
        url,
        options: _getDioOptions(),
        data: category.toJson(), // Dio envía el mapa directamente como JSON
      );
      if (response.statusCode == 201) {
        debugPrint('✅ Categoría creada exitosamente. Status: ${response.statusCode}');
        debugPrint('Cuerpo de respuesta exitosa: ${response.data}');
        return true;
      } else {
        debugPrint('❌ Error al crear categoría. Status: ${response.statusCode}');
        debugPrint('Cuerpo de la respuesta de error: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('🚨 Dio Excepción al intentar crear categoría: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('🚨 Excepción inesperada al intentar crear categoría: $e');
      return false;
    }
  }

  /// Actualiza una categoría existente en la API.
  ///
  /// Envía los datos de la categoría actualizada como JSON en una solicitud PUT.
  /// Retorna `true` si la actualización es exitosa (código 204), de lo contrario `false`.
  Future<bool> updateCategory(model.Category category) async {
    final url = '${ApiConstants.baseUrl}/api/CategoriaApi/${category.id}';
    try {
      final response = await _dio.put(
        url,
        options: _getDioOptions(),
        data: category.toJson(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Error al actualizar categoría: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error Dio al actualizar categoría: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al actualizar categoría: $e');
      return false;
    }
  }

  /// Elimina una categoría por su ID.
  ///
  /// Realiza una solicitud DELETE.
  /// Retorna `true` si la eliminación es exitosa (código 204), de lo contrario `false`.
  Future<bool> deleteCategory(int id) async {
    final url = '${ApiConstants.baseUrl}/api/CategoriaApi/$id';
    try {
      final response = await _dio.delete(
        url,
        options: _getDioOptions(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Error al eliminar categoría: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error Dio al eliminar categoría: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al eliminar categoría: $e');
      return false;
    }
  }

  // --- Métodos de Presupuestos ---

  /// Obtiene una lista de presupuestos asociados a un usuario específico.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a una lista de objetos `Budget`.
  /// Lanza una excepción si la solicitud no es exitosa.
  Future<List<Budget>> getBudgetsByUser(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi/byUser/$usuarioId';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      final List<dynamic> jsonList = response.data;
      return jsonList.map((json) => Budget.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('Error al obtener presupuestos por usuario: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener presupuestos: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error inesperado al obtener presupuestos por usuario: $e');
      throw Exception('Error inesperado al obtener presupuestos por usuario: $e');
    }
  }

  /// Obtiene un presupuesto específico por su ID.
  ///
  /// Realiza una solicitud GET y parsea la respuesta JSON a un objeto `Budget`.
  /// Retorna `null` si el presupuesto no se encuentra o si hay un error.
  Future<Budget?> getBudgetById(int id) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi/$id';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return Budget.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        debugPrint('Presupuesto no encontrado: ${e.response?.data}');
        return null;
      }
      debugPrint('Error al obtener presupuesto por ID: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener presupuesto por ID: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Error inesperado al obtener presupuesto por ID: $e');
      throw Exception('Error inesperado al obtener presupuesto por ID: $e');
    }
  }

  /// Crea un nuevo presupuesto en la API.
  ///
  /// Envía los datos del presupuesto como JSON en una solicitud POST.
  /// Formatea las fechas de inicio y fin.
  /// Imprime logs de depuración.
  /// Retorna `true` si la creación es exitosa (códigos 201 o 200), de lo contrario `false`.
  Future<bool> createBudget(Budget budget) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi';
    final data = {
      "usuarioId": budget.usuarioId,
      "nombre": budget.nombre,
      "monto": budget.monto,
      "fechaInicio": budget.fechaInicio.toIso8601String().split("T")[0],
      "fechaFin": budget.fechaFin.toIso8601String().split("T")[0],
    };

    debugPrint('🌐 ApiService - POST $url');
    debugPrint('📦 Body: $data');

    try {
      final response = await _dio.post(url, options: _getDioOptions(), data: data);
      debugPrint('🔁 Response status: ${response.statusCode}');
      debugPrint('📨 Response body: ${response.data}');
      return response.statusCode == 201 || response.statusCode == 200;
    } on DioException catch (e) {
      debugPrint('🚨 Dio Error en ApiService.createBudget: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('🚨 Error inesperado en ApiService.createBudget: $e');
      return false;
    }
  }

  /// Actualiza un presupuesto existente en la API.
  ///
  /// Envía los datos del presupuesto actualizado como JSON en una solicitud PUT.
  /// Imprime logs de depuración del proceso.
  /// Retorna `true` si la actualización es exitosa (código 204), de lo contrario `false`.
  Future<bool> updateBudget(Budget budget) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi/${budget.id}';
    final data = {
      "id": budget.id,
      "usuarioId": budget.usuarioId,
      "nombre": budget.nombre,
      "monto": budget.monto,
      "fechaInicio": budget.fechaInicio.toIso8601String().split("T")[0],
      "fechaFin": budget.fechaFin.toIso8601String().split("T")[0],
    };

    debugPrint('🔄 Actualizando presupuesto...');
    debugPrint('📤 URL: $url');
    debugPrint('🧾 Body enviado: $data');

    try {
      final response = await _dio.put(url, options: _getDioOptions(), data: data);
      debugPrint('📨 Código de respuesta: ${response.statusCode}');
      debugPrint('📩 Respuesta del servidor: ${response.data}');
      return response.statusCode == 204;
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al actualizar presupuesto: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('❌ Error inesperado al actualizar presupuesto: $e');
      return false;
    }
  }

  /// Elimina un presupuesto por su ID.
  ///
  /// Realiza una solicitud DELETE.
  /// Retorna `true` si la eliminación es exitosa (código 204), de lo contrario `false`.
  Future<bool> deleteBudget(int id) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi/$id';
    try {
      final response = await _dio.delete(
        url,
        options: _getDioOptions(),
      );
      if (response.statusCode == 204) {
        return true;
      } else {
        debugPrint('Error al eliminar presupuesto: ${response.statusCode} - ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('Error Dio al eliminar presupuesto: ${e.response?.statusCode} - ${e.message}');
      debugPrint('Cuerpo de la respuesta de error (Dio): ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Error inesperado al eliminar presupuesto: $e');
      return false;
    }
  }

  /// Obtiene los presupuestos de un usuario para un mes específico.
  ///
  /// Imprime logs de depuración.
  /// Retorna una lista de `Budget` o una lista vacía si hay un error.
  Future<List<Budget>> getBudgetsByUserAndMonth(int usuarioId, String mes) async {
    final url = '${ApiConstants.baseUrl}/api/PresupuestosApi/por-mes/$usuarioId';
    debugPrint('📅 getBudgetsByUserAndMonth()');
    debugPrint('🔗 URL: $url');
    debugPrint('🧾 Query mes: $mes');
    try {
      final response = await _dio.get(
        url,
        queryParameters: {'mes': mes},
        options: _getDioOptions(),
      );
      debugPrint('✅ Presupuestos obtenidos: ${response.data}');
      return (response.data as List).map((e) => Budget.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener presupuestos por mes: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener presupuestos por mes: $e');
      return [];
    }
  }

  // --- Métodos de Dashboard ---

  /// Obtiene los gastos agrupados por mes para un usuario específico.
  ///
  /// Retorna una lista de `MonthlyData` o lanza una excepción si hay un error.
  Future<List<MonthlyData>> getGastosPorMes(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/por-mes/$usuarioId';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return (response.data as List).map((e) => MonthlyData.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener gastos por mes: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener gastos por mes: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener gastos por mes: $e');
      throw Exception('Error inesperado al obtener gastos por mes: $e');
    }
  }

  /// Obtiene los ingresos agrupados por mes para un usuario específico.
  ///
  /// Retorna una lista de `MonthlyData` o lanza una excepción si hay un error.
  Future<List<MonthlyData>> getIngresosPorMes(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/IngresosApi/por-mes/$usuarioId';
    try {
      final response = await _dio.get(url, options: _getDioOptions());
      return (response.data as List).map((e) => MonthlyData.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener ingresos por mes: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener ingresos por mes: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener ingresos por mes: $e');
      throw Exception('Error inesperado al obtener ingresos por mes: $e');
    }
  }

  /// Obtiene el total de gastos por categoría para un usuario y un mes específicos.
  ///
  /// Retorna una lista de `CategoryTotal`.
  Future<List<CategoryTotal>> getGastosPorCategoria(int usuarioId, String mes) async {
    final url = '${ApiConstants.baseUrl}/api/GastosApi/por-categoria/$usuarioId';
    try {
      final response = await _dio.get(
        url,
        queryParameters: {
          'mes': mes,
        },
        options: _getDioOptions(),
      );
      return (response.data as List).map((json) => CategoryTotal.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener gastos por categoría: ${e.response?.statusCode} - ${e.message}');
      throw Exception('Error al obtener gastos por categoría: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener gastos por categoría: $e');
      throw Exception('Error inesperado al obtener gastos por categoría: $e');
    }
  }

  /// Obtiene recomendaciones ecológicas para un usuario específico.
  ///
  /// Imprime logs de depuración.
  /// Retorna una lista de `Recomendacion` o una lista vacía si hay un error.
  Future<List<Recomendacion>> getRecomendacionesEcologicas(int usuarioId) async {
    final url = '${ApiConstants.baseUrl}/api/RecomendacionesApi/ecologicas/$usuarioId';
    debugPrint('📗 Cargando recomendaciones ecológicas para usuario $usuarioId');
    try {
      final response = await _dio.get(
        url,
        options: _getDioOptions(),
      );
      debugPrint('📗 Recomendaciones obtenidas: ${response.data}');
      return (response.data as List).map((e) => Recomendacion.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('❌ Dio Error al obtener recomendaciones ecológicas: ${e.response?.statusCode} - ${e.message}');
      return [];
    } catch (e) {
      debugPrint('❌ Error inesperado al obtener recomendaciones ecológicas: $e');
      return [];
    }
  }

  /// Dio no necesita ser "cerrado" explícitamente como http.Client,
  /// ya que gestiona su propio ciclo de vida. Este método puede ser removido
  /// o mantenido como un placeholder si se desea.
  void closeClient() {
    debugPrint('Dio client does not require explicit closing.');
    // _dio.close(); // Esta línea podría ser usada si realmente quieres liberar recursos
                    // pero suele no ser necesaria a menos que se use `HttpClientAdapter` de forma personalizada.
  }
}