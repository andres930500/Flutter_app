import 'package:money_mind_mobile/data/models/expense_model.dart'; // Importa el modelo de datos para los gastos.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo para datos mensuales agregados.

/// `ExpenseRepository` es una **interfaz abstracta** que define el contrato
/// para las operaciones relacionadas con la gestión de gastos.
///
/// Esta interfaz especifica las funcionalidades que deben estar disponibles
/// para interactuar con los datos de gastos, sin preocuparse por los detalles
/// de la implementación subyacente (ej., si los datos provienen de una API
/// o una base de datos local). Esto promueve una arquitectura limpia y la
/// separación de responsabilidades en tu aplicación.
abstract class ExpenseRepository {
  /// Crea un nuevo gasto en el sistema.
  ///
  /// Recibe un objeto `Expense` que contiene los datos del nuevo gasto.
  /// Retorna un `Future<bool>` indicando si la operación de creación fue exitosa.
  Future<bool> createExpense(Expense expense);

  /// Obtiene una lista de todos los gastos asociados a un `usuarioId` específico.
  ///
  /// Retorna un `Future` que resuelve en una `List` de objetos `Expense`.
  Future<List<Expense>> getExpenses(int usuarioId);

  /// Obtiene un gasto específico utilizando su `id` único.
  ///
  /// Retorna un `Future` que resuelve en un objeto `Expense` si se encuentra,
  /// o `null` si no existe un gasto con el ID proporcionado.
  Future<Expense?> getExpenseById(int id);

  /// Actualiza un gasto existente en el sistema.
  ///
  /// Recibe un objeto `Expense` con los datos actualizados. Se espera que el `id`
  /// del gasto dentro del objeto `Expense` sea válido para identificar qué
  /// gasto actualizar.
  /// Retorna un `Future<bool>` indicando si la operación de actualización fue exitosa.
  Future<bool> updateExpense(Expense expense);

  /// Elimina un gasto del sistema utilizando su `id` único.
  ///
  /// Retorna un `Future<bool>` indicando si la operación de eliminación fue exitosa.
  Future<bool> deleteExpense(int id);

  /// Obtiene una lista de **gastos agrupados por mes** para un `presupuestoId` específico.
  ///
  /// Esto es útil para visualizar cómo se distribuyen los gastos a lo largo
  /// del tiempo dentro de un presupuesto dado. El resultado se presenta como una
  /// lista de `MonthlyData`, donde cada elemento contiene el nombre del mes
  /// y el monto total de gastos para ese período.
  /// Retorna un `Future` que resuelve en una `List<MonthlyData>`.
  Future<List<MonthlyData>> getGastosPorPresupuesto(int presupuestoId);
}