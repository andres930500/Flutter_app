import 'package:money_mind_mobile/domain/repositories/chart_repository.dart'; // Importa la interfaz del repositorio de gráficos.
import 'package:money_mind_mobile/data/models/monthly_data_model.dart'; // Importa el modelo de datos mensuales.
import 'package:money_mind_mobile/data/models/category_total.dart'; // Importa el modelo de totales por categoría.

/// **`GetMonthlyDataUseCase`** es un caso de uso que encapsula la lógica de negocio
/// para **obtener los ingresos y gastos de un usuario agrupados por mes**,
/// así como los gastos por categoría para un mes específico.
///
/// Este caso de uso es fundamental para alimentar los gráficos y visualizaciones
/// en el dashboard de la aplicación, proporcionando una visión general del
/// rendimiento financiero a lo largo del tiempo y por categorías.
class GetMonthlyDataUseCase {
  /// Instancia del repositorio de gráficos.
  ///
  /// Es la dependencia a través de la cual este caso de uso interactúa con
  /// la capa de datos para obtener la información necesaria para los gráficos.
  final ChartRepository repository;

  /// Constructor de `GetMonthlyDataUseCase`.
  ///
  /// Recibe una implementación de `ChartRepository`, lo que permite la
  /// **inyección de dependencias** y facilita el uso de diferentes
  /// implementaciones del repositorio (por ejemplo, para pruebas o distintas fuentes de datos).
  GetMonthlyDataUseCase(this.repository);

  /// Ejecuta la carga de **ingresos y gastos agrupados por mes** para un usuario.
  ///
  /// Recibe el `usuarioId` del usuario para el que se desean obtener los datos.
  /// Realiza llamadas concurrentes al repositorio para obtener ambos conjuntos de datos.
  ///
  /// Retorna un `Future<Map<String, List<MonthlyData>>>`:
  /// Un mapa que contiene dos claves:
  /// - `'ingresos'`: Una lista de `MonthlyData` con los ingresos totales por mes.
  /// - `'gastos'`: Una lista de `MonthlyData` con los gastos totales por mes.
  ///
  /// Lanza una `Exception` si ocurre un error durante la obtención de los datos.
  Future<Map<String, List<MonthlyData>>> execute(int usuarioId) async {
    try {
      // Obtiene los ingresos por mes de forma asíncrona.
      final ingresos = await repository.getIngresosPorMes(usuarioId);
      // Obtiene los gastos por mes de forma asíncrona.
      final gastos = await repository.getGastosPorMes(usuarioId);

      // Devuelve los resultados en un mapa para fácil acceso.
      return {
        'ingresos': ingresos,
        'gastos': gastos,
      };
    } catch (e) {
      // Captura cualquier excepción y la relanza con un mensaje más descriptivo.
      throw Exception('Error al obtener datos mensuales: $e');
    }
  }

  /// Obtiene una lista de **gastos agrupados por categoría** para un usuario y mes específicos.
  ///
  /// Recibe el `usuarioId` del usuario y el `mes` (ej. "2024-06") para el que
  /// se desean obtener los gastos por categoría. Delega la llamada al repositorio.
  ///
  /// Retorna un `Future<List<CategoryTotal>>` que contiene el total de gastos
  /// para cada categoría en el mes especificado.
  Future<List<CategoryTotal>> getGastosPorCategoria(int usuarioId, String mes) {
    return repository.getGastosPorCategoria(usuarioId, mes);
  }
}