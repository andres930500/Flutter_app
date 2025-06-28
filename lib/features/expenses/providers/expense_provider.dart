import 'package:flutter/material.dart'; // Importa las herramientas de Material Design y ChangeNotifier.
import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.
import 'package:money_mind_mobile/domain/usecases/create_expense_usecase.dart'; // Importa el caso de uso para crear un gasto.
import 'package:money_mind_mobile/domain/usecases/get_expenses_usecase.dart'; // Importa el caso de uso para obtener gastos.
import 'package:money_mind_mobile/domain/usecases/delete_expense_usecase.dart'; // Importa el caso de uso para eliminar un gasto.
import 'package:money_mind_mobile/domain/usecases/update_expense_usecase.dart'; // Importa el caso de uso para actualizar un gasto.
import 'package:money_mind_mobile/domain/usecases/get_expense_by_id_usecase.dart'; // Importa el caso de uso para obtener un gasto por ID.

/// **`ExpenseProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// relacionada con los **gastos** en la aplicación MoneyMind.
///
/// Este proveedor actúa como intermediario entre la interfaz de usuario y los
/// casos de uso (Use Cases) para realizar operaciones CRUD (Crear, Leer, Actualizar, Eliminar)
/// sobre los gastos. Se encarga de actualizar el estado de la UI (listas, indicadores de carga, errores)
/// y notificar a sus oyentes cuando hay cambios.
class ExpenseProvider extends ChangeNotifier {
  // --- Dependencias: Casos de Uso (Use Cases) ---
  /// Caso de uso para crear un nuevo gasto.
  final CreateExpenseUseCase _createExpenseUseCase;

  /// Caso de uso para obtener una lista de gastos.
  final GetExpensesUseCase _getExpensesUseCase;

  /// Caso de uso para obtener un gasto específico por su ID.
  final GetExpenseByIdUseCase _getExpenseByIdUseCase;

  /// Caso de uso para actualizar un gasto existente.
  final UpdateExpenseUseCase _updateExpenseUseCase;

  /// Caso de uso para eliminar un gasto.
  final DeleteExpenseUseCase _deleteExpenseUseCase;

  /// Constructor de `ExpenseProvider`.
  ///
  /// Recibe todas las dependencias de los casos de uso a través de la inyección
  /// de dependencias, lo que promueve un diseño modular y facilita las pruebas.
  ExpenseProvider(
    this._createExpenseUseCase,
    this._getExpensesUseCase,
    this._getExpenseByIdUseCase,
    this._updateExpenseUseCase,
    this._deleteExpenseUseCase,
  );

  // --- Variables de Estado Internas ---
  /// Lista de gastos cargados actualmente.
  List<Expense> _expenses = [];

  /// Indica si hay una operación asíncrona en curso (ej. cargando, creando, etc.).
  bool _isLoading = false;

  /// Almacena un mensaje de error si ocurre algún problema durante una operación.
  String? _error;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso a la lista de gastos.
  List<Expense> get expenses => _expenses;

  /// Indica si el proveedor está realizando una operación de carga.
  bool get isLoading => _isLoading;

  /// Proporciona el mensaje de error actual, si existe.
  String? get error => _error;

  // --- Métodos para la Lógica de Negocio ---

  /// **Carga todos los gastos** asociados a un `usuarioId` específico.
  ///
  /// Activa el estado de carga y notifica a los oyentes. Si la operación
  /// es exitosa, la lista `_expenses` se actualiza y `_error` se limpia.
  /// En caso de error, `_error` se establece con el mensaje de la excepción.
  Future<void> loadExpenses(int usuarioId) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes sobre el cambio de estado.

    try {
      _expenses = await _getExpensesUseCase.execute(
          usuarioId); // Ejecuta el caso de uso para obtener gastos.
      _error = null; // Limpia cualquier error previo si la operación es exitosa.
    } catch (e) {
      _error = 'Error al cargar gastos: $e'; // Establece el mensaje de error.
      debugPrint('❌ Error en ExpenseProvider.loadExpenses: $e'); // Imprime el error para depuración.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica nuevamente para reflejar el fin de la carga (éxito/error).
    }
  }

  /// **Crea un nuevo gasto** en el sistema.
  ///
  /// Recibe un objeto `Expense` con los datos del nuevo gasto.
  /// Activa el estado de carga y notifica a los oyentes. Si la creación es exitosa,
  /// se recarga la lista de gastos para reflejar el nuevo elemento.
  ///
  /// Retorna `true` si el gasto fue creado exitosamente, `false` en caso contrario.
  Future<bool> createExpense(Expense expense) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final success = await _createExpenseUseCase.execute(
          expense); // Ejecuta el caso de uso para crear el gasto.
      if (success) {
        await loadExpenses(
            expense.usuarioId); // Recarga la lista de gastos tras el éxito.
      }
      return success; // Retorna el resultado de la operación.
    } catch (e) {
      _error = 'Error al crear gasto: $e'; // Establece el mensaje de error.
      debugPrint('❌ Exception atrapada en ExpenseProvider.createExpense: $e');
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Actualiza un gasto existente** en el sistema.
  ///
  /// Recibe un objeto `Expense` con los datos actualizados.
  /// Activa el estado de carga y notifica a los oyentes. Si la actualización
  /// es exitosa, se recarga la lista de gastos.
  ///
  /// Retorna `true` si el gasto fue actualizado exitosamente, `false` en caso contrario.
  Future<bool> updateExpense(Expense expense) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final success = await _updateExpenseUseCase.execute(
          expense); // Ejecuta el caso de uso para actualizar el gasto.
      if (success) {
        await loadExpenses(
            expense.usuarioId); // Recarga la lista tras el éxito.
      }
      return success; // Retorna el resultado.
    } catch (e) {
      _error = 'Error al actualizar gasto: $e'; // Establece el mensaje de error.
      debugPrint('❌ Exception atrapada en ExpenseProvider.updateExpense: $e');
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Elimina un gasto** por su `id`.
  ///
  /// Recibe el `id` del gasto a eliminar y el `usuarioId` para la recarga.
  /// Activa el estado de carga y notifica a los oyentes. Si la eliminación es exitosa,
  /// se recarga la lista de gastos.
  ///
  /// Retorna `true` si el gasto fue eliminado exitosamente, `false` en caso contrario.
  Future<bool> deleteExpense(int id, int usuarioId) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final success = await _deleteExpenseUseCase.execute(
          id); // Ejecuta el caso de uso para eliminar el gasto.
      if (success) {
        await loadExpenses(
            usuarioId); // Recarga la lista tras el éxito.
      }
      return success; // Retorna el resultado.
    } catch (e) {
      _error = 'Error al eliminar gasto: $e'; // Establece el mensaje de error.
      debugPrint('❌ Exception atrapada en ExpenseProvider.deleteExpense: $e');
      return false; // Retorna falso en caso de excepción.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }

  /// **Obtiene un gasto específico** por su `id`.
  ///
  /// Recibe el `id` del gasto a obtener.
  /// Activa el estado de carga y notifica a los oyentes.
  ///
  /// Retorna el objeto `Expense` si se encuentra, o `null` si no existe o si ocurre un error.
  Future<Expense?> getExpenseById(int id) async {
    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes.
    try {
      final expense = await _getExpenseByIdUseCase.execute(
          id); // Ejecuta el caso de uso para obtener el gasto.
      _error = null; // Limpia cualquier error previo.
      return expense; // Retorna el gasto encontrado.
    } catch (e) {
      _error = 'Error al obtener gasto: $e'; // Establece el mensaje de error.
      debugPrint('❌ Exception atrapada en ExpenseProvider.getExpenseById: $e');
      return null; // Retorna null en caso de excepción o si no se encuentra.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes.
    }
  }
}