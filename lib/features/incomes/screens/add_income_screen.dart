import 'package:flutter/material.dart'; // Importa los widgets y utilidades básicas de Flutter.
import 'package:intl/intl.dart'; // Importa la librería intl para formateo de fechas.
import 'package:provider/provider.dart'; // Importa el paquete Provider para la gestión de estado.

// Importa los proveedores y modelos de datos necesarios.
import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart'; // Provee información del usuario autenticado.
import 'package:money_mind_mobile/data/models/income_model.dart'; // Modelo de datos para un ingreso.
import 'package:money_mind_mobile/data/models/category_model.dart'; // Modelo de datos para una categoría.
import 'package:money_mind_mobile/data/models/budget_model.dart'; // Modelo de datos para un presupuesto.
import 'package:money_mind_mobile/features/incomes/providers/income_provider.dart'; // Provee la lógica para añadir ingresos.
import 'package:money_mind_mobile/features/categories/providers/category_provider.dart'; // Provee la lógica para cargar categorías.
import 'package:money_mind_mobile/features/budgets/providers/budget_provider.dart'; // Provee la lógica para cargar presupuestos.

/// **`AddIncomeScreen`** es una pantalla de tipo `StatefulWidget` que permite
/// al usuario registrar un nuevo ingreso en la aplicación MoneyMind.
///
/// Ofrece campos para la descripción, monto, fecha, categoría y presupuesto asociado.
class AddIncomeScreen extends StatefulWidget {
  /// Constructor de `AddIncomeScreen`.
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

/// El estado asociado a `AddIncomeScreen`.
///
/// Gestiona los controladores de texto, los valores seleccionados y la lógica
/// para interactuar con los proveedores de datos y validar el formulario.
class _AddIncomeScreenState extends State<AddIncomeScreen> {
  // --- Claves y Controladores de Formulario ---
  /// Clave global para identificar y validar el estado del formulario.
  final _formKey = GlobalKey<FormState>();
  /// Controlador para el campo de texto de la descripción del ingreso.
  final _descriptionController = TextEditingController();
  /// Controlador para el campo de texto del monto del ingreso.
  final _amountController = TextEditingController();
  /// Controlador para el campo de texto de la fecha del ingreso.
  final _dateController = TextEditingController();

  // --- Variables de Estado para Datos Seleccionados ---
  /// Categoría de ingreso seleccionada por el usuario.
  Category? _selectedCategory;
  /// Presupuesto asociado al ingreso, opcional.
  Budget? _selectedBudget;
  /// Fecha seleccionada para el ingreso, inicializada con la fecha actual.
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Inicializa el campo de texto de la fecha con la fecha actual formateada.
    _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // `WidgetsBinding.instance.addPostFrameCallback` se usa para ejecutar código
    // una vez que el primer frame del widget ha sido renderizado.
    // Esto es necesario para interactuar con los Providers después de que el contexto
    // esté completamente disponible y la UI inicial haya sido construida.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Carga todas las categorías disponibles.
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();

      // Obtiene el ID del usuario actual para cargar sus presupuestos.
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final usuarioId = authProvider.currentUser?.id;

      if (usuarioId != null) {
        // Carga los presupuestos asociados al usuario actual.
        Provider.of<BudgetProvider>(context, listen: false).loadBudgets(usuarioId);
      } else {
        // Mensaje de depuración si el ID de usuario no está disponible.
        debugPrint('⚠️ No se pudo obtener el usuarioId para cargar presupuestos');
      }
    });
  }

  @override
  void dispose() {
    // Libera los recursos de los controladores de texto para evitar fugas de memoria.
    _descriptionController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Muestra un selector de fecha para que el usuario elija la fecha del ingreso.
  Future<void> _selectDate(BuildContext context) async {
    // Muestra el DatePicker.
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Fecha inicial mostrada.
      firstDate: DateTime(2000), // Fecha mínima seleccionable.
      lastDate: DateTime(2101), // Fecha máxima seleccionable.
    );
    // Si se seleccionó una fecha y es diferente de la actual.
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // Actualiza la fecha seleccionada.
        // Actualiza el campo de texto de la fecha con el formato deseado.
        _dateController.text = DateFormat('yyyy-MM-dd').format(_selectedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene las instancias de los Providers.
    // El `listen: true` por defecto asegura que el widget se reconstruya cuando
    // el estado de estos proveedores cambie (ej. al cargar categorías/presupuestos,
    // o al cambiar el estado de guardado del ingreso).
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final incomeProvider = Provider.of<IncomeProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);

    // Filtra las categorías para mostrar solo las de tipo 'ingreso'.
    final ingresoCategories = categoryProvider.categories
        .where((c) => c.tipo.trim().toLowerCase() == 'ingreso')
        .toList();

    // Obtiene los presupuestos disponibles del `BudgetProvider`.
    final availableBudgets = budgetProvider.budgets;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Ingreso'), // Título de la barra de la aplicación.
        centerTitle: true, // Centra el título.
        backgroundColor: Colors.green.shade500, // Color de fondo de la barra.
        foregroundColor: Colors.white, // Color del texto y los íconos.
      ),
      body: SingleChildScrollView(
        // Permite que el contenido del formulario sea desplazable si es demasiado largo.
        padding: const EdgeInsets.all(24.0), // Espaciado general del cuerpo.
        child: Card(
          elevation: 6, // Sombra para dar efecto de elevación.
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)), // Bordes redondeados.
          child: Padding(
            padding: const EdgeInsets.all(20.0), // Espaciado interno de la tarjeta.
            child: Form(
              key: _formKey, // Asigna la clave del formulario para su validación.
              child: Column(
                children: [
                  const Text(
                    'Nuevo Ingreso', // Título dentro de la tarjeta.
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green, // Color del título.
                    ),
                  ),
                  const SizedBox(height: 20), // Espacio vertical.

                  // --- Campo de Descripción ---
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => value == null || value.isEmpty
                        ? 'Ingresa una descripción'
                        : null, // Regla de validación.
                  ),
                  const SizedBox(height: 20),

                  // --- Campo de Monto ---
                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.number, // Teclado numérico.
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Ingresa un monto';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Monto inválido'; // Valida que sea un número.
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // --- Campo de Fecha (Solo lectura con selector) ---
                  TextFormField(
                    controller: _dateController,
                    readOnly: true, // Hace el campo de solo lectura para obligar al uso del selector.
                    decoration: InputDecoration(
                      labelText: 'Fecha',
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onTap: () => _selectDate(context), // Abre el selector de fecha al tocar.
                    validator: (value) => value == null || value.isEmpty
                        ? 'Selecciona una fecha'
                        : null, // Regla de validación.
                  ),
                  const SizedBox(height: 20),

                  // --- Selector de Presupuesto (Opcional) ---
                  // Muestra un mensaje de carga si no hay presupuestos disponibles.
                  availableBudgets.isEmpty
                      ? const Center(child: Text('No hay presupuestos disponibles.'))
                      : DropdownButtonFormField<Budget>(
                          decoration: InputDecoration(
                            labelText: 'Presupuesto (Opcional)',
                            prefixIcon: const Icon(Icons.account_balance_wallet),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: availableBudgets
                              .map((budget) => DropdownMenuItem(
                                    value: budget,
                                    child: Text(budget.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedBudget = value), // Actualiza el presupuesto seleccionado.
                          value: _selectedBudget, // Valor actualmente seleccionado.
                        ),
                  const SizedBox(height: 20),

                  // --- Selector de Categoría (Obligatorio) ---
                  // Muestra un mensaje de carga si las categorías no han cargado aún.
                  ingresoCategories.isEmpty
                      ? const Center(child: Text('🔄 Cargando categorías de ingreso...'))
                      : DropdownButtonFormField<Category>(
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: ingresoCategories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCategory = value), // Actualiza la categoría seleccionada.
                          validator: (value) => value == null
                              ? 'Selecciona una categoría'
                              : null, // Regla de validación.
                          value: _selectedCategory, // Valor actualmente seleccionado.
                        ),
                  const SizedBox(height: 30),

                  // --- Botón de Guardar Ingreso ---
                  SizedBox(
                    width: double.infinity, // El botón ocupa todo el ancho disponible.
                    height: 50, // Altura fija del botón.
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save), // Icono de guardar.
                      label: const Text(
                        'Guardar Ingreso',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600, // Color de fondo del botón.
                        foregroundColor: Colors.white, // Color del texto e icono.
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // Bordes redondeados.
                        ),
                      ),
                      // El botón está deshabilitado (`null`) si `incomeProvider.isSaving` es `true`.
                      onPressed: incomeProvider.isSaving
                          ? null // Deshabilita el botón mientras se guarda.
                          : () async {
                              // Valida el formulario antes de intentar guardar.
                              if (_formKey.currentState!.validate()) {
                                // Doble verificación para la categoría (el validador del Dropdown también lo hace).
                                if (_selectedCategory == null) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Por favor, selecciona una categoría.')),
                                    );
                                  }
                                  return; // Sale si no hay categoría seleccionada.
                                }

                                // Crea una nueva instancia de `Income` con los datos del formulario.
                                final newIncome = Income(
                                  id: 0, // El ID será asignado por el backend/base de datos.
                                  usuarioId: authProvider.currentUser!.id, // ID del usuario actual.
                                  presupuestoId: _selectedBudget?.id, // ID del presupuesto seleccionado (puede ser null).
                                  categoriaId: _selectedCategory!.id, // ID de la categoría seleccionada.
                                  descripcion: _descriptionController.text
                                      .trim(), // Descripción del ingreso.
                                  monto: double.parse(_amountController.text
                                      .trim()), // Monto parseado a double.
                                  fecha: _selectedDate, // Fecha seleccionada.
                                );

                                // Llama al método `addIncome` del `IncomeProvider` para guardar.
                                final success =
                                    await incomeProvider.addIncome(newIncome);

                                if (success) {
                                  // Si el guardado fue exitoso.
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('✅ Ingreso agregado exitosamente')),
                                    );
                                    Navigator.pop(context); // Regresa a la pantalla anterior.
                                  }
                                } else {
                                  // Si el guardado falló.
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              '❌ Error al agregar ingreso. Intenta de nuevo.')),
                                    );
                                  }
                                }
                              }
                            },
                    ),
                  ),
                  // Muestra un indicador de progreso si se está guardando.
                  if (incomeProvider.isSaving)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}