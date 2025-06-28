/// La clase `MonthlyData` representa datos agregados por mes, ideal para
/// visualizaciones como gráficos de barras o líneas en un dashboard.
///
/// Este modelo encapsula un **valor monetario** (`monto`)
/// asociado a un **mes específico** (`mes`). Por ejemplo, podrías usarlo para
/// mostrar los ingresos o gastos totales de un mes en particular.
class MonthlyData {
  /// El nombre del mes al que corresponden los datos (ej. "Enero", "Febrero").
  final String mes;

  /// El monto total agregado para ese mes.
  final double monto;

  /// Constructor de la clase `MonthlyData`.
  ///
  /// Requiere que se proporcionen el `mes` y el `monto` al crear una instancia.
  MonthlyData({required this.mes, required this.monto});

  /// **Constructor `factory` `fromJson`** para crear una instancia de `MonthlyData`
  /// a partir de un mapa JSON.
  ///
  /// Se utiliza al recibir datos agregados por mes desde una API.
  /// Asume que el JSON de entrada contendrá:
  /// - Una clave `'mes'` para el nombre del mes. Si esta clave es nula en el JSON,
  ///   se usará una cadena vacía (`''`) como valor por defecto.
  /// - Una clave `'total'` para el monto agregado. Es importante notar que tu backend
  ///   podría usar 'total' en lugar de 'monto' para el valor numérico en este tipo de agregaciones.
  ///   El valor se convierte a `double`, y si `'total'` es nulo, se usará `0.0`.
  factory MonthlyData.fromJson(Map<String, dynamic> json) {
    return MonthlyData(
      mes: json['mes'] ?? '', // Proporciona un valor por defecto si 'mes' es nulo.
      monto: (json['total'] ?? 0).toDouble(), // Convierte 'total' a double; usa 0.0 si es nulo.
    );
  }

  /// **Método `toJson`** para convertir una instancia de `MonthlyData` a un mapa JSON.
  ///
  /// Este método es útil si necesitas serializar este objeto de nuevo a un formato JSON,
  /// por ejemplo, para almacenamiento local o para enviar datos a un backend.
  /// Aquí, la clave para el valor monetario se mantiene como `'monto'`, lo cual es
  /// consistente con la propiedad interna del modelo en Flutter.
  Map<String, dynamic> toJson() {
    return {
      'mes': mes,
      'monto': monto, // Se mantiene 'monto' como la clave para la serialización a JSON.
    };
  }
}