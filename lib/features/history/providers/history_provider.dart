import 'package:flutter/material.dart'; // Importa las herramientas de Material Design y ChangeNotifier.
import 'package:money_mind_mobile/data/models/transaction_history_item_model.dart'; // Importa el modelo de datos para un ítem del historial de transacciones.
import 'package:money_mind_mobile/domain/usecases/get_transactions_history_usecase.dart'; // Importa el caso de uso para obtener el historial de transacciones.
import 'package:money_mind_mobile/data/repositories/history_repository_impl.dart'; // Importa la implementación del repositorio de historial.

/// **`HistoryProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica de negocio
/// para la pantalla del historial de transacciones en la aplicación MoneyMind.
///
/// Este proveedor es responsable de cargar, almacenar y filtrar la lista de transacciones
/// para un usuario, permitiendo la visualización del historial en la UI.
class HistoryProvider extends ChangeNotifier {
  // --- Dependencia: Caso de Uso (Use Case) ---
  /// Caso de uso para obtener los datos del historial de transacciones.
  /// Se inyecta para promover la flexibilidad y facilitar las pruebas.
  final GetTransactionsHistoryUseCase _getTransactionsHistoryUseCase;

  /// Constructor de `HistoryProvider`.
  ///
  /// Permite la inyección de una instancia de `GetTransactionsHistoryUseCase`.
  /// Si no se proporciona ninguna instancia (es decir, es `null`), se crea una
  /// por defecto utilizando `HistoryRepositoryImpl()`. Esto es útil para la
  /// configuración de producción donde se usa la implementación real del repositorio,
  /// mientras que en pruebas se podría inyectar un mock.
  HistoryProvider({
    GetTransactionsHistoryUseCase? getTransactionsHistoryUseCase,
  }) : _getTransactionsHistoryUseCase = getTransactionsHistoryUseCase ??
            GetTransactionsHistoryUseCase(HistoryRepositoryImpl()); // Usa la implementación por defecto si no se inyecta

  // --- Variables de Estado Internas ---
  /// Lista de ítems del historial de transacciones cargados actualmente.
  List<TransactionHistoryItem> _transactions = [];

  /// Indica si hay una operación asíncrona de carga de transacciones en curso.
  bool _isLoading = false;

  /// Fecha de inicio seleccionada para filtrar el historial. Puede ser nula si no hay filtro.
  DateTime? _startDate;

  /// Fecha de fin seleccionada para filtrar el historial. Puede ser nula si no hay filtro.
  DateTime? _endDate;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso a la lista de transacciones.
  List<TransactionHistoryItem> get transactions => _transactions;

  /// Indica si el proveedor está cargando transacciones.
  bool get isLoading => _isLoading;

  /// Proporciona la fecha de inicio del filtro actual.
  DateTime? get startDate => _startDate;

  /// Proporciona la fecha de fin del filtro actual.
  DateTime? get endDate => _endDate;

  // --- Métodos para la Lógica de Filtros y Actualización de Estado ---

  /// **Establece la fecha de inicio del filtro** y notifica a los oyentes.
  ///
  /// * `date`: La nueva fecha de inicio. Puede ser `null` para quitar el filtro.
  void setStartDate(DateTime? date) {
    _startDate = date; // Actualiza la fecha de inicio.
    notifyListeners(); // Notifica a los widgets que escuchan para que se reconstruyan.
  }

  /// **Establece la fecha de fin del filtro** y notifica a los oyentes.
  ///
  /// * `date`: La nueva fecha de fin. Puede ser `null` para quitar el filtro.
  void setEndDate(DateTime? date) {
    _endDate = date; // Actualiza la fecha de fin.
    notifyListeners(); // Notifica a los widgets que escuchan para que se reconstruyan.
  }

  /// **Limpia los filtros de fecha** (establece `_startDate` y `_endDate` a `null`)
  /// y notifica a los oyentes.
  void clearDates() {
    _startDate = null; // Reinicia la fecha de inicio.
    _endDate = null; // Reinicia la fecha de fin.
    notifyListeners(); // Notifica a los widgets que escuchan.
  }

  // --- Método Principal para Cargar Transacciones ---

  /// **Carga las transacciones del historial** para un usuario dado,
  /// aplicando los filtros de fecha actualmente seleccionados.
  ///
  /// Este método es llamado desde la UI (ej. al iniciar la pantalla o al aplicar filtros).
  ///
  /// * `usuarioId`: El ID del usuario cuyas transacciones se desean cargar.
  Future<void> loadTransactions(int usuarioId) async {
    // Protección para evitar llamadas duplicadas si ya hay una carga en progreso.
    if (_isLoading) return;

    _isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a la UI que la carga ha comenzado (ej. para mostrar un `CircularProgressIndicator`).

    try {
      // Ejecuta el caso de uso `GetTransactionsHistoryUseCase`, pasando el ID del usuario
      // y las fechas de inicio y fin actuales como parámetros de filtro.
      _transactions = await _getTransactionsHistoryUseCase.execute(
        usuarioId: usuarioId,
        startDate: _startDate,
        endDate: _endDate,
      );
      // Imprime un mensaje de depuración con el número de transacciones cargadas.
      debugPrint('Historial cargado: ${_transactions.length} transacciones.');
      // En un caso real, aquí podrías manejar cualquier lógica post-carga exitosa,
      // como ordenar las transacciones o transformarlas.
    } catch (e) {
      // Captura cualquier error que ocurra durante la carga de transacciones.
      debugPrint('❌ Error al cargar el historial de transacciones: $e');
      _transactions = []; // Vacía la lista de transacciones en caso de error para evitar mostrar datos incorrectos.
      // Aquí podrías añadir una lógica para establecer una variable de error interna
      // y notificar a la UI para que muestre un mensaje de error al usuario.
    } finally {
      _isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a la UI que la carga ha finalizado (ya sea con éxito o con error).
    }
  }
}
