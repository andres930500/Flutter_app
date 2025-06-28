import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.
import 'package:fl_chart/fl_chart.dart'; // Importa la librería fl_chart para crear gráficos.

import 'package:money_mind_mobile/features/dashboard/providers/filtered_chart_provider.dart'; // Importa el proveedor de datos filtrados para los gráficos.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos de presupuesto.

/// **`DashboardScreen`** es la pantalla principal que muestra un resumen financiero
/// al usuario, incluyendo la capacidad de filtrar datos por año, mes y presupuesto,
/// y visualizar ingresos y gastos en un gráfico de barras.
class DashboardScreen extends StatefulWidget {
  /// El ID del usuario actual, necesario para cargar sus datos financieros.
  final int usuarioId;

  /// Constructor de `DashboardScreen`.
  const DashboardScreen({super.key, required this.usuarioId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// El estado mutable de `DashboardScreen`.
class _DashboardScreenState extends State<DashboardScreen> {
  /// Almacena el año seleccionado actualmente por el usuario, inicializado con el año actual.
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // Utiliza `addPostFrameCallback` para asegurar que el `context` esté disponible
    // antes de intentar acceder al `Provider`. Esto es una buena práctica para
    // operaciones que necesitan el `context` justo después de que el widget se ha construido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtiene la instancia de `FilteredChartProvider` sin escuchar (`listen: false`)
      // ya que solo necesitamos llamar a un método y no reconstruir el widget por cambios iniciales.
      final provider = Provider.of<FilteredChartProvider>(context, listen: false);

      // Determina el nombre del mes actual (ej. 'Enero', 'Febrero')
      // Restamos 1 a `DateTime.now().month` porque los meses en `provider.meses`
      // están indexados desde 0 (Enero es el índice 0).
      final mesActual = provider.meses[DateTime.now().month - 1];

      // Convierte el año actual a String, ya que el método `selectMes` lo espera así.
      final anioActual = DateTime.now().year.toString();

      // Llama al método del proveedor para cargar los presupuestos y datos
      // para el mes y año iniciales.
      provider.selectMes(widget.usuarioId, mesActual, anioActual);
    });
  }

  /// Método `build` que describe la parte de la interfaz de usuario representada por este widget.
  ///
  /// Construye la UI de la pantalla del Dashboard, incluyendo selectores de año, mes y presupuesto,
  /// y un gráfico de barras que visualiza los ingresos y gastos.
  @override
  Widget build(BuildContext context) {
    // Escucha los cambios en `FilteredChartProvider` para reconstruir la UI
    // cuando los datos, el estado de carga o los filtros cambian.
    final provider = Provider.of<FilteredChartProvider>(context);

    // Obtiene los datos de ingresos y gastos del proveedor.
    final ingresos = provider.ingresos;
    final gastos = provider.gastos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen Financiero 📊'), // Título de la barra de la aplicación.
        centerTitle: true, // Centra el título.
      ),
      body: provider.isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Muestra un indicador de carga si los datos están cargando.
          : Padding(
              padding: const EdgeInsets.all(16.0), // Espaciado general.
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Alinea los widgets a la izquierda.
                children: [
                  const Text(
                    'Selecciona año, mes y presupuesto', // Título para la sección de selección.
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // --- Dropdown de Años ---
                  DropdownButton<int>(
                    hint: const Text('Selecciona un año'), // Texto de sugerencia.
                    value: _selectedYear, // El año actualmente seleccionado.
                    isExpanded: true, // El dropdown ocupa todo el ancho disponible.
                    items: List.generate(5, (index) {
                      // Genera opciones para el año actual y los 4 años anteriores.
                      final year = DateTime.now().year - index;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()), // Muestra el año como texto.
                      );
                    }).toList(),
                    onChanged: (year) {
                      if (year != null) {
                        setState(() {
                          _selectedYear = year; // Actualiza el año seleccionado en el estado local.
                        });
                        // Vuelve a cargar los datos para el mes actualmente seleccionado (o el mes actual por defecto)
                        // y el nuevo año. Esto asegura que los presupuestos y los datos se actualicen según el año.
                        final mesActual =
                            provider.selectedMes ?? provider.meses[DateTime.now().month - 1];
                        provider.selectMes(widget.usuarioId, mesActual, year.toString());
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // --- Dropdown de Meses ---
                  DropdownButton<String>(
                    hint: const Text('Selecciona un mes'), // Texto de sugerencia.
                    value: provider
                        .selectedMes, // El mes actualmente seleccionado del proveedor.
                    isExpanded: true,
                    items: provider.meses
                        .map((mes) => DropdownMenuItem(
                              value: mes,
                              child: Text(mes), // Muestra el nombre del mes.
                            ))
                        .toList(),
                    onChanged: (mes) {
                      if (mes != null) {
                        // Llama al método del proveedor para seleccionar el nuevo mes
                        // y el año que ya está seleccionado.
                        provider.selectMes(widget.usuarioId, mes, _selectedYear.toString());
                      }
                    },
                  ),

                  const SizedBox(height: 12),

                  // --- Dropdown de Presupuestos del mes ---
                  // Este es un `DropdownButton` estándar que muestra los presupuestos cargados
                  // por el `FilteredChartProvider` para el mes y año seleccionados.
                  DropdownButton<Budget>(
                    hint: const Text('Selecciona un presupuesto'), // Texto de sugerencia.
                    value: provider
                        .selectedPresupuesto, // El presupuesto actualmente seleccionado.
                    isExpanded: true,
                    items: provider.presupuestos // Lista de presupuestos disponibles.
                        .map((pres) => DropdownMenuItem(
                              value: pres,
                              child: Text(pres.nombre), // Muestra el nombre del presupuesto.
                            ))
                        .toList(),
                    onChanged: (presupuesto) {
                      if (presupuesto != null) {
                        // Llama al método del proveedor para seleccionar el presupuesto,
                        // lo que a su vez cargará los ingresos y gastos para ese presupuesto.
                        provider.selectPresupuesto(presupuesto.id);
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // --- Sección de Gráficos ---
                  // Condición para mostrar la gráfica o un mensaje si no hay datos.
                  if (ingresos.isEmpty && gastos.isEmpty)
                    const Center(
                      child: Text("No hay datos suficientes para mostrar gráficos."),
                    )
                  else ...[
                    // Título del gráfico.
                    const Text(
                      'Ingresos vs Gastos',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      // El `Expanded` permite que el gráfico ocupe el espacio restante verticalmente.
                      child: BarChart(
                        // Widget de gráfico de barras de `fl_chart`.
                        BarChartData(
                          barGroups: _buildBarGroups(
                              ingresos, gastos), // Datos para las barras de la gráfica.
                          titlesData: FlTitlesData(
                            // Configuración de los títulos de los ejes.
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true, // Muestra títulos en el eje X (inferior).
                                getTitlesWidget: (value, _) {
                                  // Función para generar las etiquetas del eje X.
                                  final index = value.toInt();
                                  if (index < ingresos.length) {
                                    // Muestra las primeras 3 letras del mes como etiqueta.
                                    return Text(
                                      ingresos[index].mes.substring(0, 3),
                                      style: const TextStyle(fontSize: 10),
                                    );
                                  }
                                  return const Text(''); // Retorna vacío si no hay datos.
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize:
                                      40), // Muestra títulos en el eje Y (izquierdo) con un tamaño reservado.
                            ),
                            rightTitles: AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)), // No muestra títulos en el eje Y (derecho).
                            topTitles: AxisTitles(
                                sideTitles:
                                    SideTitles(showTitles: false)), // No muestra títulos en el eje X (superior).
                          ),
                          gridData: FlGridData(
                              show: true), // Muestra la cuadrícula de fondo.
                          borderData: FlBorderData(
                              show: false), // No muestra el borde alrededor del gráfico.
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  /// Método auxiliar para construir los grupos de barras (`BarChartGroupData`)
  /// para el gráfico de ingresos vs. gastos.
  ///
  /// Combina los datos de ingresos y gastos en pares de barras para cada punto de datos.
  ///
  /// * `ingresos`: Lista de `MonthlyData` para los ingresos.
  /// * `gastos`: Lista de `MonthlyData` para los gastos.
  ///
  /// Retorna una lista de `BarChartGroupData` que `fl_chart` puede renderizar.
  List<BarChartGroupData> _buildBarGroups(
    List<MonthlyData> ingresos,
    List<MonthlyData> gastos,
  ) {
    // Determina la longitud máxima entre las listas de ingresos y gastos para asegurar
    // que todas las barras correspondientes sean consideradas en el gráfico.
    final maxLength =
        ingresos.length > gastos.length ? ingresos.length : gastos.length;

    List<BarChartGroupData> barGroups = [];

    // Itera a través de los datos para crear un `BarChartGroupData` por cada mes/índice.
    for (int i = 0; i < maxLength; i++) {
      // Obtiene el monto de ingresos; si el índice excede el tamaño de la lista, usa 0.0.
      final ingreso = i < ingresos.length ? ingresos[i].monto : 0.0;
      // Obtiene el monto de gastos; si el índice excede el tamaño de la lista, usa 0.0.
      final gasto = i < gastos.length ? gastos[i].monto : 0.0;

      // Agrega un `BarChartGroupData` al `barGroups`. Cada grupo representa un punto
      // en el eje X y contiene las barras de ingresos y gastos para ese punto.
      barGroups.add(
        BarChartGroupData(
          x: i, // El valor del eje X (índice) para este grupo de barras.
          barRods: [
            // Primera barra: para los ingresos (color verde).
            BarChartRodData(toY: ingreso, color: Colors.green, width: 8),
            // Segunda barra: para los gastos (color rojo).
            BarChartRodData(toY: gasto, color: Colors.red, width: 8),
          ],
        ),
      );
    }

    return barGroups; // Retorna la lista de grupos de barras construidos.
  }
}