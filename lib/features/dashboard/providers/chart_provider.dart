import 'package:flutter/material.dart'; // Importa las herramientas de Material Design y ChangeNotifier.
import 'package:money_mind_mobile/domain/usecases/get_monthly_data_usecase.dart'; // Importa el caso de uso para obtener datos mensuales.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/data/models/category_total.dart'; // Importa el modelo para los totales por categoría.

/// **`ChartProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// relacionada con los datos utilizados para gráficos financieros en la aplicación MoneyMind.
///
/// Este proveedor se encarga de cargar datos mensuales de ingresos y gastos,
/// así como los gastos desglosados por categoría, y notifica a sus oyentes
/// sobre cualquier cambio en estos datos o en el estado de carga/error.
class ChartProvider with ChangeNotifier {
  /// Caso de uso para obtener los datos mensuales y los gastos por categoría.
  final GetMonthlyDataUseCase useCase;

  // --- Variables de Estado Internas ---
  /// Lista de los totales de gastos agrupados por categoría.
  List<CategoryTotal> gastosPorCategoria = [];

  /// El mes actualmente seleccionado para mostrar los gastos por categoría.
  String selectedMes = '';

  /// Lista de datos mensuales de ingresos.
  List<MonthlyData> ingresos = [];

  /// Lista de datos mensuales de gastos.
  List<MonthlyData> gastos = [];

  /// Indica si hay una operación asíncrona en curso (ej. cargando datos).
  bool isLoading = false;

  /// Almacena un mensaje de error si ocurre algún problema durante una operación.
  String? errorMessage;

  /// Constructor de `ChartProvider`.
  ///
  /// Recibe la instancia de `GetMonthlyDataUseCase` a través de inyección de dependencias.
  ChartProvider(this.useCase);

  // --- Métodos para la Lógica de Negocio ---

  /// **Carga los datos mensuales de ingresos y gastos** para un `usuarioId` específico.
  ///
  /// Activa el estado de carga, limpia mensajes de error previos y notifica a los oyentes.
  /// Luego, ejecuta el caso de uso para obtener los datos. Si la operación es exitosa,
  /// actualiza las listas `ingresos` y `gastos` y limpia `errorMessage`.
  /// En caso de error, establece el mensaje de error y vacía las listas.
  /// Finalmente, desactiva el estado de carga y notifica nuevamente a los oyentes.
  Future<void> loadMonthlyData(int usuarioId) async {
    isLoading = true; // Activa el indicador de carga.
    errorMessage = null; // Limpia cualquier mensaje de error previo.
    notifyListeners(); // Notifica a los widgets que escuchan sobre el inicio de la carga.

    try {
      // Ejecuta el caso de uso para obtener los datos mensuales.
      final data = await useCase.execute(usuarioId);
      // Asigna los datos obtenidos, usando listas vacías como fallback si son nulos.
      ingresos = data['ingresos'] ?? [];
      gastos = data['gastos'] ?? [];
    } catch (e) {
      errorMessage =
          'Error al cargar los datos del gráfico: $e'; // Captura y establece el mensaje de error.
      ingresos = []; // Vacía la lista de ingresos en caso de error.
      gastos = []; // Vacía la lista de gastos en caso de error.
    } finally {
      isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes sobre el fin de la carga (éxito o error).
    }
  }

  /// **Carga los gastos agrupados por categoría** para un `usuarioId` y `mes` específicos.
  ///
  /// Similar a `loadMonthlyData`, activa el estado de carga, limpia errores y notifica.
  /// Ejecuta el método `getGastosPorCategoria` del caso de uso.
  /// Si tiene éxito, actualiza `gastosPorCategoria` y `selectedMes`.
  /// En caso de error, establece el mensaje de error y vacía la lista de categorías.
  /// Finalmente, desactiva el estado de carga y notifica.
  Future<void> loadGastosPorCategoria(int usuarioId, String mes) async {
    isLoading = true; // Activa el indicador de carga.
    errorMessage = null; // Limpia cualquier mensaje de error previo.
    notifyListeners(); // Notifica a los oyentes sobre el inicio de la carga.

    try {
      // Ejecuta el método específico del caso de uso para obtener gastos por categoría.
      final data = await useCase.getGastosPorCategoria(usuarioId, mes);
      gastosPorCategoria = data; // Asigna los datos de gastos por categoría.
      selectedMes = mes; // Almacena el mes para el cual se cargaron los datos.
    } catch (e) {
      errorMessage =
          'Error al cargar categorías: $e'; // Captura y establece el mensaje de error.
      gastosPorCategoria = []; // Vacía la lista de categorías en caso de error.
    } finally {
      isLoading = false; // Desactiva el indicador de carga.
      notifyListeners(); // Notifica a los oyentes sobre el fin de la carga.
    }
  }
}