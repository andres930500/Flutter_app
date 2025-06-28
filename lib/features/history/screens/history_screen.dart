import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.
import 'package:intl/intl.dart'; // Importa para formatear fechas y monedas.
import 'package:flutter/foundation.dart'; // Importar para debugPrint (aunque ya está en HistoryProvider, es buena práctica si se usa aquí).

// Importa el proveedor del historial.
import 'package:money_mind_mobile/features/history/providers/history_provider.dart';
// Importa los modelos de Income y Expense que ya tienes. (Nota: Si TransactionHistoryItem
// unifica ambos, estos podrían no ser estrictamente necesarios en la UI,
// pero se mantienen por si se necesitan propiedades específicas no generalizadas).
import 'package:money_mind_mobile/data/models/income_model.dart';
import 'package:money_mind_mobile/data/models/expense_model.dart';
// Importa el modelo común para elementos de historial.
import 'package:money_mind_mobile/data/models/transaction_history_item_model.dart';

/// **`HistoryScreen`** es una pantalla de Flutter que muestra el historial de movimientos
/// (gastos e ingresos) de un usuario, con la capacidad de filtrar por rango de fechas.
class HistoryScreen extends StatefulWidget {
  /// El ID del usuario para el cual se mostrará el historial. Es un parámetro requerido.
  final int usuarioId;

  /// Constructor de `HistoryScreen`.
  const HistoryScreen({super.key, required this.usuarioId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

/// El estado mutable de `HistoryScreen`.
class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    // `WidgetsBinding.instance.addPostFrameCallback` asegura que el `context`
    // esté completamente inicializado y disponible antes de acceder al `Provider`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Obtiene el `HistoryProvider`. `listen: false` se usa porque no necesitamos
      // reconstruir el widget solo por esta lectura inicial.
      final provider = Provider.of<HistoryProvider>(context, listen: false);
      // Carga las transacciones al iniciar la pantalla usando el ID del usuario.
      provider.loadTransactions(widget.usuarioId);
    });
  }

  /// Método asíncrono para **seleccionar una fecha de inicio** para el filtro.
  ///
  /// Muestra un `DatePicker` al usuario. Si se selecciona una fecha válida y diferente,
  /// actualiza el `startDate` en el `HistoryProvider` y recarga las transacciones.
  Future<void> _selectStartDate(BuildContext context) async {
    // Obtiene el proveedor sin escuchar cambios, solo para llamar a sus métodos.
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      // Fecha inicial del selector: si ya hay una fecha de inicio, úsala;
      // de lo contrario, usa la fecha actual menos 30 días.
      initialDate: provider.startDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2000), // Fecha más temprana permitida.
      lastDate: DateTime.now(), // Fecha más tardía permitida (hoy).
    );
    // Si se seleccionó una fecha y es diferente a la actual fecha de inicio.
    if (picked != null && picked != provider.startDate) {
      provider.setStartDate(picked); // Actualiza la fecha de inicio en el proveedor.
      // Recarga las transacciones aplicando el nuevo filtro de fecha de inicio.
      provider.loadTransactions(widget.usuarioId);
    }
  }

  /// Método asíncrono para **seleccionar una fecha de fin** para el filtro.
  ///
  /// Muestra un `DatePicker` al usuario. Si se selecciona una fecha válida y diferente,
  /// actualiza el `endDate` en el `HistoryProvider` y recarga las transacciones.
  Future<void> _selectEndDate(BuildContext context) async {
    // Obtiene el proveedor sin escuchar cambios.
    final provider = Provider.of<HistoryProvider>(context, listen: false);
    final DateTime? picked = await showDatePicker(
      context: context,
      // Fecha inicial del selector: si ya hay una fecha de fin, úsala; de lo contrario, usa la fecha actual.
      initialDate: provider.endDate ?? DateTime.now(),
      // La fecha de inicio del selector no puede ser anterior a la fecha de inicio ya seleccionada,
      // o a una fecha muy antigua si no hay fecha de inicio establecida.
      firstDate: provider.startDate ?? DateTime(2000),
      lastDate: DateTime.now(), // Fecha más tardía permitida (hoy).
    );
    // Si se seleccionó una fecha y es diferente a la actual fecha de fin.
    if (picked != null && picked != provider.endDate) {
      provider.setEndDate(picked); // Actualiza la fecha de fin en el proveedor.
      // Recarga las transacciones aplicando el nuevo filtro de fecha de fin.
      provider.loadTransactions(widget.usuarioId);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene el esquema de colores del tema actual para consistencia visual.
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Movimientos'), // Título de la barra de aplicación.
        centerTitle: true, // Centra el título.
        backgroundColor: colorScheme.primary, // Color de fondo de la barra, tomado del tema.
        foregroundColor: Colors.white, // Color del texto y los íconos en la barra.
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Espaciado general alrededor del cuerpo.
        child: Column(
          // Organiza los elementos verticalmente: filtros y lista de transacciones.
          children: [
            // --- Sección de filtros de fecha ---
            Card(
              elevation: 4, // Sombra para la tarjeta.
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Bordes redondeados.
              margin: const EdgeInsets.only(bottom: 16.0), // Margen inferior para separarlo de la lista.
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Espaciado dentro de la tarjeta.
                // `Consumer` escucha los cambios en `HistoryProvider` y reconstruye
                // solo esta parte del árbol de widgets cuando el proveedor notifica cambios.
                child: Consumer<HistoryProvider>(
                  builder: (context, provider, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Alinea el contenido a la izquierda.
                      children: [
                        const Text(
                          'Filtrar por Fecha:', // Título para la sección de filtros.
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12), // Espacio vertical.
                        Row(
                          // Organiza los selectores de fecha "Desde" y "Hasta" horizontalmente.
                          children: [
                            Expanded(
                              // Permite que el selector de fecha "Desde" ocupe el espacio disponible.
                              child: InkWell(
                                // Permite que el `InputDecorator` sea interactivo al toque.
                                onTap: () => _selectStartDate(context), // Llama al método para seleccionar fecha de inicio.
                                child: InputDecorator(
                                  // Muestra el campo de fecha con estilo de entrada de texto.
                                  decoration: InputDecoration(
                                    labelText: 'Desde', // Etiqueta del campo.
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)), // Bordes redondeados.
                                    suffixIcon: const Icon(Icons.calendar_today), // Icono de calendario.
                                  ),
                                  child: Text(
                                    // Muestra la fecha seleccionada formateada, o un mensaje predeterminado.
                                    provider.startDate != null
                                        ? DateFormat('dd/MM/yyyy').format(provider.startDate!)
                                        : 'Seleccionar fecha',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16), // Espacio horizontal entre los selectores.
                            Expanded(
                              // Permite que el selector de fecha "Hasta" ocupe el espacio disponible.
                              child: InkWell(
                                onTap: () => _selectEndDate(context), // Llama al método para seleccionar fecha de fin.
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Hasta', // Etiqueta del campo.
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)), // Bordes redondeados.
                                    suffixIcon: const Icon(Icons.calendar_today), // Icono de calendario.
                                  ),
                                  child: Text(
                                    // Muestra la fecha seleccionada formateada, o un mensaje predeterminado.
                                    provider.endDate != null
                                        ? DateFormat('dd/MM/yyyy').format(provider.endDate!)
                                        : 'Seleccionar fecha',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12), // Espacio vertical.
                        // Botón para limpiar los filtros de fecha.
                        Align(
                          alignment: Alignment.centerRight, // Alinea el botón a la derecha.
                          child: ElevatedButton.icon(
                            onPressed: () {
                              provider.clearDates(); // Limpia las fechas en el proveedor.
                              provider.loadTransactions(widget
                                  .usuarioId); // Recarga las transacciones sin filtros.
                            },
                            icon: const Icon(Icons.clear), // Icono de limpiar.
                            label: const Text('Limpiar Fechas'), // Texto del botón.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade300, // Color de fondo del botón.
                              foregroundColor: Colors.black87, // Color del texto e icono.
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)), // Bordes redondeados.
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),

            // --- Sección del historial de transacciones (lista dinámica) ---
            Expanded(
              // Permite que la lista ocupe el espacio restante.
              child: Consumer<HistoryProvider>(
                // `Consumer` escucha los cambios en `HistoryProvider` para reconstruir la lista.
                builder: (context, provider, child) {
                  // Muestra un indicador de progreso si las transacciones están cargando.
                  if (provider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Muestra un mensaje si no hay transacciones para las fechas seleccionadas.
                  if (provider.transactions.isEmpty) {
                    return const Center(
                        child: Text(
                            'No hay movimientos en el historial para las fechas seleccionadas.'));
                  }

                  // Construye la lista de transacciones si hay datos.
                  return ListView.builder(
                    itemCount: provider.transactions.length, // Número total de ítems.
                    itemBuilder: (context, index) {
                      final item = provider.transactions[
                          index]; // Obtiene el TransactionHistoryItem actual.

                      // Variables para personalizar la apariencia de cada ítem (gasto/ingreso).
                      Color itemColor; // Color de fondo de la tarjeta del ítem.
                      IconData itemIcon; // Icono del ítem.
                      Color iconAndTextColor; // Color para el icono y el texto del monto.
                      String amountSign; // Signo (+/-) para el monto.

                      // Determina los colores, iconos y signos basados en si es un gasto o un ingreso.
                      if (item.isExpense) {
                        itemColor = Colors.red.shade100; // Rojo claro para gastos.
                        itemIcon = Icons.money_off; // Icono de dinero tachado.
                        iconAndTextColor = Colors.red.shade700; // Rojo oscuro para icono y monto.
                        amountSign = '- '; // Signo negativo.
                      } else {
                        itemColor = Colors.green.shade100; // Verde claro para ingresos.
                        itemIcon = Icons.attach_money; // Icono de dinero.
                        iconAndTextColor = Colors.green.shade700; // Verde oscuro para icono y monto.
                        amountSign = '+ '; // Signo positivo.
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0), // Margen vertical entre tarjetas.
                        elevation: 2, // Poca sombra para las tarjetas de la lista.
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)), // Bordes redondeados.
                        color: itemColor, // Color de fondo de la tarjeta (rojo/verde claro).
                        child: ListTile(
                          leading: Icon(itemIcon,
                              size: 30, color: iconAndTextColor), // Icono a la izquierda.
                          title: Text(
                            item.descripcion, // Descripción de la transacción.
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            DateFormat('dd/MM/yyyy')
                                .format(item.fecha), // Fecha formateada de la transacción.
                            style: const TextStyle(color: Colors.black54),
                          ),
                          trailing: Text(
                            // Monto formateado con signo y símbolo de moneda colombiana.
                            amountSign +
                                NumberFormat.currency(locale: 'es_CO', symbol: '\$')
                                    .format(item.monto),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: iconAndTextColor, // Color del monto (rojo/verde oscuro).
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}