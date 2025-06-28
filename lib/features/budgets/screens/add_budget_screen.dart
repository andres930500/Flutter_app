import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.

import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart'; // Importa el AuthProvider para obtener el usuario actual.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.
import 'package:money_mind_mobile/features/budgets/providers/budget_provider.dart'; // Importa el BudgetProvider para interactuar con la lógica de presupuestos.

/// **`AddBudgetScreen`** es la pantalla de interfaz de usuario que permite a los usuarios
/// crear un nuevo presupuesto.
///
/// Los usuarios pueden introducir un nombre, un monto total, una fecha de inicio
/// y una fecha de fin para el presupuesto. La pantalla utiliza `BudgetProvider`
/// para manejar la lógica de creación y `AuthProvider` para obtener el ID del usuario actual.
class AddBudgetScreen extends StatefulWidget {
  /// Constructor de `AddBudgetScreen`.
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

/// El estado mutable de `AddBudgetScreen`.
class _AddBudgetScreenState extends State<AddBudgetScreen> {
  /// Clave global para el `Form`, utilizada para validar los campos de texto.
  final _formKey = GlobalKey<FormState>();

  /// Controladores de texto para los campos de nombre y monto del presupuesto.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  /// Variables para almacenar las fechas de inicio y fin seleccionadas.
  DateTime? _startDate;
  DateTime? _endDate;

  /// Método `dispose` para liberar los recursos de los `TextEditingController`
  /// cuando el widget se elimina del árbol.
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Función asíncrona para mostrar el selector de fechas.
  ///
  /// Recibe el `BuildContext` y un booleano `isStart` para determinar
  /// si se está seleccionando la fecha de inicio o de fin.
  /// Actualiza la variable de estado (`_startDate` o `_endDate`) con la fecha seleccionada.
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // La fecha inicial mostrada en el selector.
      firstDate: DateTime(2024), // La primera fecha disponible para seleccionar.
      lastDate: DateTime(2100), // La última fecha disponible para seleccionar.
      helpText: isStart // Texto de ayuda que varía según si es fecha de inicio o fin.
          ? 'Selecciona la fecha de inicio'
          : 'Selecciona la fecha de fin',
    );
    if (picked != null) {
      // Si se selecciona una fecha, actualiza el estado.
      setState(() {
        if (isStart) {
          _startDate = picked; // Asigna la fecha a `_startDate`.
        } else {
          _endDate = picked; // Asigna la fecha a `_endDate`.
        }
      });
    }
  }

  /// Método `build` que describe la parte de la interfaz de usuario representada por este widget.
  ///
  /// Construye el formulario para añadir un nuevo presupuesto, incluyendo campos de texto
  /// y selectores de fecha. También maneja la lógica de validación y la interacción
  /// con `BudgetProvider` para guardar el presupuesto.
  @override
  Widget build(BuildContext context) {
    // Obtiene el usuario actual del AuthProvider (no escucha cambios aquí).
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    // Obtiene la instancia de BudgetProvider (escucha cambios para indicadores de carga/errores).
    final provider = Provider.of<BudgetProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Nuevo Presupuesto"), // Título de la barra de la aplicación.
        centerTitle: true, // Centra el título.
        backgroundColor: Colors.green.shade600, // Color de fondo de la barra.
        foregroundColor: Colors.white, // Color del texto y los iconos en la barra.
      ),
      body: SingleChildScrollView(
        // Permite el desplazamiento si el contenido excede el tamaño de la pantalla.
        padding: const EdgeInsets.all(24), // Espaciado alrededor del contenido.
        child: Card(
          // Una tarjeta para agrupar los campos del formulario.
          elevation: 5, // Sombra para el efecto de elevación.
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)), // Bordes redondeados.
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey, // Asocia la clave global para la validación del formulario.
              child: Column(
                children: [
                  // Título principal del formulario.
                  const Text(
                    'Crear Presupuesto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Color distintivo.
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo de texto para el nombre del presupuesto.
                  TextFormField(
                    controller: _nameController, // Vincula el controlador de texto.
                    decoration: InputDecoration(
                      labelText: 'Nombre del presupuesto', // Etiqueta del campo.
                      prefixIcon: const Icon(Icons.title), // Icono decorativo.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                      ),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Campo requerido' : null, // Validación simple.
                  ),
                  const SizedBox(height: 16),

                  // Campo de texto para el monto total del presupuesto.
                  TextFormField(
                    controller: _amountController, // Vincula el controlador de texto.
                    decoration: InputDecoration(
                      labelText: 'Monto total', // Etiqueta del campo.
                      prefixIcon: const Icon(Icons.attach_money), // Icono de dinero.
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                      ),
                    ),
                    keyboardType: TextInputType.number, // Teclado numérico.
                    validator: (v) => v == null || double.tryParse(v) == null
                        ? 'Monto inválido'
                        : null, // Validación de número.
                  ),
                  const SizedBox(height: 20),

                  // Widget para seleccionar la fecha de inicio.
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Elimina el padding predeterminado.
                    title: Text(
                      _startDate == null
                          ? 'Selecciona fecha de inicio'
                          : 'Inicio: ${_startDate!.toLocal().toString().split(' ')[0]}', // Muestra la fecha seleccionada.
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today), // Icono de calendario.
                      onPressed: () => _selectDate(context, true), // Llama al selector de fecha.
                    ),
                  ),

                  // Widget para seleccionar la fecha de fin.
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Elimina el padding predeterminado.
                    title: Text(
                      _endDate == null
                          ? 'Selecciona fecha de fin'
                          : 'Fin: ${_endDate!.toLocal().toString().split(' ')[0]}', // Muestra la fecha seleccionada.
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_month), // Icono de calendario.
                      onPressed: () => _selectDate(context, false), // Llama al selector de fecha.
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Botón para guardar el presupuesto.
                  SizedBox(
                    width: double.infinity, // Ocupa todo el ancho disponible.
                    height: 50, // Altura fija.
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save), // Icono de guardar.
                      label: const Text('Guardar Presupuesto'), // Texto del botón.
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700, // Color de fondo del botón.
                        foregroundColor: Colors.white, // Color del texto y icono.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      onPressed: () async {
                        print('🟢 Botón "Guardar Presupuesto" presionado');

                        // Valida el formulario y verifica que las fechas estén seleccionadas.
                        if (_formKey.currentState!.validate() &&
                            _startDate != null &&
                            _endDate != null) {
                          print('✅ Formulario válido y fechas seleccionadas');

                          // Crea una instancia de Budget con los datos del formulario.
                          final budget = Budget(
                            id: 0, // El ID se asignará en el backend.
                            usuarioId: user.id, // ID del usuario actual.
                            nombre: _nameController.text.trim(), // Nombre del presupuesto.
                            monto: double.parse(_amountController.text), // Monto parseado a double.
                            fechaInicio: _startDate!, // Fecha de inicio seleccionada.
                            fechaFin: _endDate!, // Fecha de fin seleccionada.
                            usuario: user, // Asigna el objeto de usuario completo.
                          );

                          print('📦 Datos del presupuesto a enviar: ${budget.toJson()}');

                          try {
                            // Intenta crear el presupuesto usando el BudgetProvider.
                            final success = await provider.createBudget(budget);

                            if (!mounted) return; // Verifica si el widget sigue montado.

                            if (success) {
                              print('✅ Presupuesto guardado con éxito');
                              // Muestra un SnackBar de éxito y regresa a la pantalla anterior.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Presupuesto guardado'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                              Navigator.pop(context); // Vuelve a la pantalla anterior.
                            } else {
                              print(
                                  '❌ Error en el provider: createBudget devolvió false');
                              // Muestra un SnackBar de error si la operación falla en el provider.
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('❌ Error al guardar presupuesto'),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          } catch (e) {
                            print('🚨 Excepción al guardar presupuesto: $e');
                            // Muestra un SnackBar para errores inesperados.
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('⚠️ Error inesperado al guardar presupuesto'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } else {
                          print('⚠️ Formulario inválido o fechas no seleccionadas');
                          // Muestra un SnackBar si la validación del formulario falla.
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('⚠️ Completa todos los campos y fechas'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}