import 'package:flutter/material.dart'; // Importa las herramientas básicas de Material Design y los widgets de Flutter.
import 'package:money_mind_mobile/domain/usecases/create_income_usecase.dart'; // Importa el caso de uso para crear un ingreso.
import 'package:money_mind_mobile/data/models/income_model.dart'; // Importa el modelo de datos para un ingreso.

/// **`IncomeProvider`** es un `ChangeNotifier` que gestiona el estado y la lógica
/// de negocio relacionada con la adición de nuevos ingresos en la aplicación MoneyMind.
///
/// Su principal responsabilidad es intermediar entre la interfaz de usuario y el
/// caso de uso encargado de registrar un ingreso, además de manejar el estado de carga.
class IncomeProvider extends ChangeNotifier {
  // --- Dependencia: Caso de Uso (Use Case) ---
  /// Caso de uso para la creación de ingresos. Se inyecta a través del constructor
  /// para desacoplar las responsabilidades y facilitar las pruebas.
  final CreateIncomeUseCase _createIncomeUseCase;

  /// Constructor de `IncomeProvider`.
  ///
  /// Recibe una instancia de `CreateIncomeUseCase` que utilizará para realizar
  /// la operación de creación de ingresos.
  IncomeProvider(this._createIncomeUseCase);

  // --- Variables de Estado Internas ---
  /// Indica si una operación de guardado (creación de ingreso) está en curso.
  bool _isSaving = false;

  // --- Getters Públicos para Acceder al Estado ---
  /// Proporciona acceso al estado de guardado actual.
  /// `true` si se está guardando un ingreso, `false` en caso contrario.
  bool get isSaving => _isSaving;

  // --- Métodos para la Lógica de Negocio ---

  /// **Añade un nuevo ingreso** a través del caso de uso.
  ///
  /// Este método es el punto de entrada para que la UI solicite el registro de un ingreso.
  ///
  /// * `income`: El objeto `Income` que contiene los datos del ingreso a registrar.
  ///
  /// Retorna `true` si el ingreso se registró con éxito, `false` en caso de error.
  Future<bool> addIncome(Income income) async {
    // 1. Inicia el estado de carga:
    _isSaving = true; // Establece el indicador de que se está guardando.
    notifyListeners(); // Notifica a todos los widgets que escuchan que el estado ha cambiado,
                        // lo que permite a la UI mostrar un indicador de carga (ej. un `CircularProgressIndicator`).

    try {
      // 2. Ejecuta el caso de uso:
      // Delega la lógica real de persistencia al `CreateIncomeUseCase`.
      // El `await` pausa la ejecución hasta que el caso de uso completa su operación.
      final result = await _createIncomeUseCase.execute(income);
      return result; // Retorna el resultado (éxito/falla) de la operación del caso de uso.
    } catch (e) {
      // 3. Manejo de errores:
      // Si ocurre alguna excepción durante la ejecución del caso de uso, se captura aquí.
      debugPrint('Error al registrar ingreso: $e'); // Imprime el error para depuración.
      return false; // Retorna `false` para indicar que la operación falló.
    } finally {
      // 4. Finaliza el estado de carga:
      // Este bloque se ejecuta siempre, independientemente de si hubo éxito o error.
      _isSaving = false; // Desactiva el indicador de guardado.
      notifyListeners(); // Notifica a la UI que la operación ha finalizado,
                          // permitiendo ocultar el indicador de carga.
    }
  }
}