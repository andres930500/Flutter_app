import 'package:flutter/material.dart'; // Importa las herramientas de Material Design y ChangeNotifier.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos de presupuesto.

import 'package:money_mind_mobile/domain/usecases/get_gastos_por_presupuesto_usecase.dart'; // Importa el caso de uso para obtener gastos por presupuesto.
import 'package:money_mind_mobile/domain/usecases/get_ingresos_por_presupuesto_usecase.dart'; // Importa el caso de uso para obtener ingresos por presupuesto.
import 'package:money_mind_mobile/domain/usecases/get_budgets_by_user_and_month_usecase.dart'; // Importa el caso de uso para obtener presupuestos por usuario y mes.

/// **`FilteredChartProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// para los gráficos filtrados por mes y presupuesto en la aplicación MoneyMind.
///
/// Este proveedor permite a los usuarios seleccionar un mes y, opcionalmente, un presupuesto
/// específico para visualizar los ingresos y gastos relacionados.
class FilteredChartProvider extends ChangeNotifier {
  // --- Dependencias: Casos de Uso (Use Cases) ---
  /// Caso de uso para obtener ingresos asociados a un presupuesto específico.
  final GetIngresosPorPresupuestoUseCase getIngresosPorPresupuestoUseCase;

  /// Caso de uso para obtener gastos asociados a un presupuesto específico.
  final GetGastosPorPresupuestoUseCase getGastosPorPresupuestoUseCase;

  /// Caso de uso para obtener los presupuestos de un usuario filtrados por mes y año.
  final GetBudgetsByUserAndMonthUseCase getPresupuestosUseCase;

  /// Constructor de `FilteredChartProvider`.
  ///
  /// Recibe todas las dependencias de los casos de uso a través de la inyección
  /// de dependencias, lo que promueve un diseño modular y facilita las pruebas.
  FilteredChartProvider({
    required this.getIngresosPorPresupuestoUseCase,
    required this.getGastosPorPresupuestoUseCase,
    required this.getPresupuestosUseCase,
  });

  // --- Variables de Estado Internas ---
  /// Indica si hay una operación asíncrona en curso (ej. cargando datos).
  bool isLoading = false;

  /// Lista de nombres de los meses del año, utilizada para la selección en la UI.
  final List<String> meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  /// Mapa que relaciona el nombre del mes con su representación numérica (formato 'MM').
  final Map<String, String> mesesMap = {
    'Enero': '01',
    'Febrero': '02',
    'Marzo': '03',
    'Abril': '04',
    'Mayo': '05',
    'Junio': '06',
    'Julio': '07',
    'Agosto': '08',
    'Septiembre': '09',
    'Octubre': '10',
    'Noviembre': '11',
    'Diciembre': '12',
  };

  /// El mes actualmente seleccionado por el usuario.
  String? selectedMes;

  /// Lista de presupuestos disponibles para el mes y año seleccionados.
  List<Budget> presupuestos = [];

  /// El presupuesto actualmente seleccionado por el usuario para filtrar datos.
  Budget? selectedPresupuesto;

  /// Lista de datos mensuales de ingresos filtrados.
  List<MonthlyData> ingresos = [];

  /// Lista de datos mensuales de gastos filtrados.
  List<MonthlyData> gastos = [];

  // --- Métodos para la Lógica de Negocio ---

  /// **Selecciona un mes y carga los presupuestos** disponibles para ese mes y año.
  ///
  /// Restablece el presupuesto seleccionado y los datos de ingresos/gastos.
  /// Luego, formatea el mes y el año para obtener los presupuestos correspondientes
  /// usando `getPresupuestosUseCase`. Notifica a los oyentes sobre los cambios de estado.
  ///
  /// * `usuarioId`: El ID del usuario actual.
  /// * `mesNombre`: El nombre del mes seleccionado (ej. 'Enero').
  /// * `anio`: El año seleccionado (ej. '2024').
  Future<void> selectMes(int usuarioId, String mesNombre, String anio) async {
    isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes sobre el inicio de la carga.

    selectedMes = mesNombre; // Actualiza el mes seleccionado.
    selectedPresupuesto = null; // Reinicia el presupuesto seleccionado.
    ingresos = []; // Limpia los ingresos.
    gastos = []; // Limpia los gastos.

    // Formatea el mes a un formato 'YYYY-MM' requerido por el caso de uso.
    final mesFormateado = '$anio-${mesesMap[mesNombre]!}';
    // Obtiene los presupuestos para el usuario en el mes y año especificados.
    presupuestos =
        await getPresupuestosUseCase.execute(usuarioId, mesFormateado);

    isLoading = false; // Desactiva el indicador de carga.
    notifyListeners(); // Notifica a los oyentes sobre el fin de la carga y la actualización de presupuestos.
  }

  /// **Selecciona un presupuesto y carga los ingresos y gastos** asociados a él.
  ///
  /// Actualiza el presupuesto seleccionado y luego utiliza los casos de uso
  /// `getIngresosPorPresupuestoUseCase` y `getGastosPorPresupuestoUseCase`
  /// para obtener los datos financieros específicos de ese presupuesto.
  /// Notifica a los oyentes sobre los cambios de estado.
  ///
  /// * `presupuestoId`: El ID del presupuesto seleccionado.
  Future<void> selectPresupuesto(int presupuestoId) async {
    isLoading = true; // Activa el indicador de carga.
    notifyListeners(); // Notifica a los oyentes sobre el inicio de la carga.

    // Encuentra el presupuesto seleccionado en la lista de presupuestos disponibles.
    selectedPresupuesto = presupuestos.firstWhere((p) => p.id == presupuestoId);

    // Obtiene los ingresos asociados al presupuesto seleccionado.
    ingresos =
        await getIngresosPorPresupuestoUseCase.execute(presupuestoId);
    // Obtiene los gastos asociados al presupuesto seleccionado.
    gastos = await getGastosPorPresupuestoUseCase.execute(presupuestoId);

    isLoading = false; // Desactiva el indicador de carga.
    notifyListeners(); // Notifica a los oyentes sobre el fin de la carga y la actualización de ingresos/gastos.
  }
}