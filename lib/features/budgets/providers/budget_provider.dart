// lib/features/budgets/providers/budget_provider.dart
import 'package:flutter/material.dart'; // Importa las herramientas de Material Design y ChangeNotifier.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.
import 'package:money_mind_mobile/domain/usecases/create_budget_usecase.dart'; // Importa el caso de uso para crear un presupuesto.
import 'package:money_mind_mobile/domain/usecases/get_budgets_usecase.dart'; // Importa el caso de uso para obtener todos los presupuestos.
import 'package:money_mind_mobile/domain/usecases/get_budget_by_id_usecase.dart'; // Importa el caso de uso para obtener un presupuesto por ID.
import 'package:money_mind_mobile/domain/usecases/update_budget_usecase.dart'; // Importa el caso de uso para actualizar un presupuesto.
import 'package:money_mind_mobile/domain/usecases/delete_budget_usecase.dart'; // Importa el caso de uso para eliminar un presupuesto.

/// **`BudgetProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// relacionada con los **presupuestos** en la aplicación.
///
/// Este proveedor interactúa con los casos de uso (Use Cases) para realizar
/// operaciones CRUD (Crear, Leer, Actualizar, Eliminar) sobre los presupuestos,
/// actualizando el estado de la UI y notificando a sus oyentes.
class BudgetProvider extends ChangeNotifier {
  // --- Dependencias: Casos de Uso (Use Cases) ---
  /// Caso de uso para crear un nuevo presupuesto.
  final CreateBudgetUseCase _createBudgetUseCase;

  /// Caso de uso para obtener una lista de presupuestos.
  final GetBudgetsUseCase _getBudgetsUseCase;

  /// Caso de uso para obtener un presupuesto específico por su ID.
  final GetBudgetByIdUseCase _getBudgetByIdUseCase;

  /// Caso de uso para actualizar un presupuesto existente.
  final UpdateBudgetUseCase _updateBudgetUseCase;

  /// Caso de uso para eliminar un presupuesto.
  final DeleteBudgetUseCase _deleteBudgetUseCase;

  // --- Variables de Estado Internas ---
  /// Lista de presupuestos cargados actualmente.
  List<Budget> _budgets = [];

  /// Indica si hay una operación asíncrona en curso (ej. cargando, creando, etc.).
  bool _isLoading = false;

  /// Almacena un mensaje de error si ocurre algún problema durante una operación.
  String? _error;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso a la lista de presupuestos.
  List<Budget> get budgets => _budgets;

  /// Indica si el proveedor está realizando una operación de carga.
  bool get isLoading => _isLoading;

  /// Proporciona el mensaje de error actual, si existe.
  String? get error => _error;

  /// Constructor de `BudgetProvider`.
  ///
  /// Recibe todas las dependencias de los casos de uso a través de la inyección
  /// de dependencias, lo que promueve un diseño modular y facilita las pruebas.
  BudgetProvider(
    this._createBudgetUseCase,
    this._getBudgetsUseCase,
    this._getBudgetByIdUseCase,
    this._updateBudgetUseCase,
    this._deleteBudgetUseCase,
  );

  // --- Métodos para la Lógica de Negocio ---

  /// **Carga todos los presupuestos** asociados a un `usuarioId` específico.
  ///
  /// Actualiza el estado de carga y notifica a los oyentes. Si la operación
  /// es exitosa, la lista `_budgets` se actualiza y `_error` se limpia.
  /// En caso de error, `_error` se establece con el mensaje de la excepción.
  Future<void> loadBudgets(int usuarioId) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los widgets que escuchan sobre el cambio de estado.

    try {
      _budgets = await _getBudgetsUseCase.execute(
          usuarioId); // Ejecuta el caso de uso para obtener presupuestos.
      _error = null; // Limpia cualquier error previo si la operación es exitosa.
    } catch (e) {
      _error = 'Error al cargar presupuestos: $e'; // Establece el mensaje de error.
      debugPrint(
          '❌ Error en BudgetProvider.loadBudgets: $e'); // Imprime el error para depuración.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica nuevamente para reflejar el fin de la carga (éxito/error).
    }
  }

  /// **Crea un nuevo presupuesto** en el sistema.
  ///
  /// Recibe un objeto `Budget` con los datos del nuevo presupuesto.
  /// Si la creación es exitosa, se recarga la lista de presupuestos para reflejar
  /// el nuevo elemento.
  ///
  /// Retorna `true` si el presupuesto fue creado exitosamente, `false` en caso contrario.
  Future<bool> createBudget(Budget budget) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    debugPrint('📤 BudgetProvider - createBudget() iniciado');
    debugPrint('📦 Presupuesto a enviar: ${budget.toJson()}');

    try {
      final success = await _createBudgetUseCase.execute(
          budget); // Ejecuta el caso de uso para crear el presupuesto.
      debugPrint('✅ Resultado del useCase: $success');

      if (success) {
        debugPrint('🔄 Recargando lista de presupuestos...');
        await loadBudgets(
            budget.usuarioId); // Recarga la lista de presupuestos tras el éxito.
      }
      return success; // Retorna el resultado de la operación.
    } catch (e) {
      _error = 'Error al crear presupuesto: $e'; // Establece el mensaje de error.
      debugPrint(
          '❌ Exception atrapada en BudgetProvider.createBudget: $_error'); // Imprime el error.
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Actualiza un presupuesto existente** en el sistema.
  ///
  /// Recibe un objeto `Budget` con los datos actualizados. Si la actualización
  /// es exitosa, se recarga la lista de presupuestos.
  ///
  /// Retorna `true` si el presupuesto fue actualizado exitosamente, `false` en caso contrario.
  Future<bool> updateBudget(Budget budget) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final success = await _updateBudgetUseCase.execute(
          budget); // Ejecuta el caso de uso para actualizar el presupuesto.
      if (success)
        await loadBudgets(
            budget.usuarioId); // Recarga la lista tras el éxito.
      return success; // Retorna el resultado.
    } catch (e) {
      _error = 'Error al actualizar presupuesto: $e'; // Establece el mensaje de error.
      debugPrint(
          '❌ Exception atrapada en BudgetProvider.updateBudget: $e'); // Imprime el error.
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Elimina un presupuesto** por su `id`.
  ///
  /// Recibe el `id` del presupuesto a eliminar y el `usuarioId` para la recarga.
  /// Si la eliminación es exitosa, se recarga la lista de presupuestos.
  ///
  /// Retorna `true` si el presupuesto fue eliminado exitosamente, `false` en caso contrario.
  Future<bool> deleteBudget(int id, int usuarioId) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final success = await _deleteBudgetUseCase.execute(
          id); // Ejecuta el caso de uso para eliminar el presupuesto.
      if (success)
        await loadBudgets(
            usuarioId); // Recarga la lista tras el éxito.
      return success; // Retorna el resultado.
    } catch (e) {
      _error = 'Error al eliminar presupuesto: $e'; // Establece el mensaje de error.
      debugPrint(
          '❌ Exception atrapada en BudgetProvider.deleteBudget: $e'); // Imprime el error.
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Obtiene un presupuesto específico** por su `id`.
  ///
  /// Retorna el objeto `Budget` si se encuentra, o `null` si no existe o si ocurre un error.
  Future<Budget?> getBudgetById(int id) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final budget = await _getBudgetByIdUseCase.execute(
          id); // Ejecuta el caso de uso para obtener el presupuesto.
      _error = null; // Limpia cualquier error previo.
      return budget; // Retorna el presupuesto encontrado.
    } catch (e) {
      _error = 'Error al obtener presupuesto por ID: $e'; // Establece el mensaje de error.
      debugPrint(
          '❌ Exception atrapada en BudgetProvider.getBudgetById: $e'); // Imprime el error.
      return null; // Retorna null en caso de excepción o si no se encuentra.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }
}