import 'package:money_mind_mobile/data/models/budget_model.dart'; // Importa el modelo de datos para los presupuestos.

/// **`BudgetRepository`** es una interfaz abstracta que define el contrato
/// para las operaciones relacionadas con la gestión de presupuestos.
///
/// Esta interfaz especifica qué funcionalidades deben estar disponibles para
/// interactuar con los datos de presupuestos, sin preocuparse por los detalles
/// de cómo se implementan (ej. si vienen de una API, una base de datos local, etc.).
/// Esto promueve una arquitectura limpia y la separación de responsabilidades.
abstract class BudgetRepository {
  /// Obtiene una lista de todos los presupuestos asociados a un `usuarioId` específico.
  ///
  /// Retorna un `Future` que resuelve en una `List` de objetos `Budget`.
  Future<List<Budget>> getBudgetsByUser(int usuarioId); // ✅ Agregado

  /// Obtiene una lista de presupuestos para un `usuarioId` específico y un `mes` determinado.
  ///
  /// El `mes` generalmente se espera en un formato como "YYYY-MM".
  /// Retorna un `Future` que resuelve en una `List` de objetos `Budget`.
  Future<List<Budget>> getBudgetsByUserAndMonth(int usuarioId, String mes);

  /// Obtiene un presupuesto específico utilizando su `id` único.
  ///
  /// Retorna un `Future` que resuelve en un objeto `Budget` si se encuentra,
  /// o `null` si no existe un presupuesto con el ID proporcionado.
  Future<Budget?> getBudgetById(int id);

  /// Crea un nuevo presupuesto en el sistema.
  ///
  /// Recibe un objeto `Budget` que contiene los datos del nuevo presupuesto.
  /// Retorna un `Future<bool>` indicando si la operación de creación fue exitosa.
  Future<bool> createBudget(Budget budget);

  /// Actualiza un presupuesto existente en el sistema.
  ///
  /// Recibe un objeto `Budget` con los datos actualizados. Se espera que el `id`
  /// del presupuesto dentro del objeto `Budget` sea válido para identificar qué
  /// presupuesto actualizar.
  /// Retorna un `Future<bool>` indicando si la operación de actualización fue exitosa.
  Future<bool> updateBudget(Budget budget);

  /// Elimina un presupuesto del sistema utilizando su `id` único.
  ///
  /// Retorna un `Future<bool>` indicando si la operación de eliminación fue exitosa.
  Future<bool> deleteBudget(int id);
}