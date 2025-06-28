import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:money_mind_mobile/features/auth/providers/auth_provider.dart';
import 'package:money_mind_mobile/data/models/expense_model.dart';
import 'package:money_mind_mobile/data/models/category_model.dart';
import 'package:money_mind_mobile/data/models/budget_model.dart';

import 'package:money_mind_mobile/features/expenses/providers/expense_provider.dart';
import 'package:money_mind_mobile/features/categories/providers/category_provider.dart';
import 'package:money_mind_mobile/features/budgets/providers/budget_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();

  Category? _selectedCategory;
  Budget? _selectedBudget;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Provider.of<AuthProvider>(context, listen: false).currentUser!.id;
      Provider.of<CategoryProvider>(context, listen: false).loadCategories();
      Provider.of<BudgetProvider>(context, listen: false).loadBudgets(userId);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final expenseCategories =
        categoryProvider.categories.where((c) => c.tipo.toLowerCase() == 'gasto').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Gasto'),
        centerTitle: true,
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Nuevo Gasto',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      prefixIcon: const Icon(Icons.description),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Ingresa una descripción' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: 'Monto',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Ingresa un monto';
                      if (double.tryParse(value) == null) return 'Monto inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        controller: TextEditingController(
                          text: "${_selectedDate.toLocal()}".split(' ')[0],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  DropdownButtonFormField<Budget>(
                    decoration: InputDecoration(
                      labelText: 'Presupuesto (opcional)',
                      prefixIcon: const Icon(Icons.account_balance_wallet),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    items: budgetProvider.budgets
                        .map((budget) => DropdownMenuItem(
                              value: budget,
                              child: Text(budget.nombre),
                            ))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedBudget = value),
                    value: _selectedBudget,
                    isExpanded: true,
                  ),
                  const SizedBox(height: 20),

                  expenseCategories.isEmpty
                      ? const Center(child: Text("🔄 Cargando categorías..."))
                      : DropdownButtonFormField<Category>(
                          decoration: InputDecoration(
                            labelText: 'Categoría',
                            prefixIcon: const Icon(Icons.category),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: expenseCategories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.nombre),
                                  ))
                              .toList(),
                          onChanged: (value) => setState(() => _selectedCategory = value),
                          validator: (value) =>
                              value == null ? 'Selecciona una categoría' : null,
                        ),
                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Gasto', style: TextStyle(fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade600,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final newExpense = Expense(
                            id: 0,
                            usuarioId: authProvider.currentUser!.id,
                            presupuestoId: _selectedBudget?.id,
                            categoriaId: _selectedCategory!.id,
                            descripcion: _descriptionController.text.trim(),
                            monto: double.parse(_amountController.text.trim()),
                            fecha: _selectedDate,
                          );

                          final success = await expenseProvider.createExpense(newExpense);
                          if (success && mounted) {
                            Navigator.pop(context);
                          } else {
                            if (mounted && expenseProvider.error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error al guardar gasto: ${expenseProvider.error}'),
                                  duration: const Duration(days: 1), // permanece en pantalla
                                  action: SnackBarAction(
                                    label: 'Cerrar',
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                    },
                                  ),
                                ),
                              );
                            }
                          }
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
