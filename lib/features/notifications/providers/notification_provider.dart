// lib/features/notifications/providers/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert'; // Para codificar/decodificar mensajes JSON

class NotificationProvider extends ChangeNotifier {
  WebSocketChannel? _channel; // El canal WebSocket
  bool _isConnected = false; // Estado de la conexión
  String? _lastNotification; // Última notificación recibida
  String? _errorMessage; // Mensaje de error de la conexión

  bool get isConnected => _isConnected;
  String? get lastNotification => _lastNotification;
  String? get errorMessage => _errorMessage;

  // Puedes definir la URL de tu servidor WebSocket aquí.
  // Asegúrate que tu backend tenga un servidor WebSocket ejecutándose.
  // Ejemplo: ws://tu_ip_local:8080/ws (para desarrollo)
  // o wss://tu_dominio.com/ws (para producción con SSL)
  final String _wsUrl;

  NotificationProvider(this._wsUrl) {
    _connectWebSocket(); // Intenta conectar al inicializar el provider
  }

  // Método para conectar al servidor WebSocket
  void _connectWebSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _isConnected = true;
      _errorMessage = null; // Limpia errores previos
      notifyListeners();

      _channel!.stream.listen(
        (message) {
          // Cuando se recibe un mensaje del servidor
          debugPrint('📢 Mensaje WebSocket recibido: $message');
          _lastNotification = message; // Almacena la notificación
          // Aquí puedes parsear el mensaje si es JSON
          // Map<String, dynamic> notificationData = jsonDecode(message);
          // Puedes crear un modelo de notificación aquí si tienes datos estructurados
          notifyListeners(); // Notifica a los oyentes sobre la nueva notificación
        },
        onDone: () {
          // Cuando la conexión se cierra
          debugPrint('🔌 Conexión WebSocket cerrada');
          _isConnected = false;
          _errorMessage = 'Conexión cerrada. Intentando reconectar...';
          notifyListeners();
          // Intenta reconectar después de un breve retraso
          Future.delayed(const Duration(seconds: 5), _connectWebSocket);
        },
        onError: (error) {
          // Cuando ocurre un error en la conexión
          debugPrint('❌ Error WebSocket: $error');
          _isConnected = false;
          _errorMessage = 'Error de conexión: $error. Intentando reconectar...';
          notifyListeners();
          // Intenta reconectar después de un breve retraso
          Future.delayed(const Duration(seconds: 5), _connectWebSocket);
        },
      );
    } catch (e) {
      debugPrint('🚨 Error al conectar WebSocket: $e');
      _isConnected = false;
      _errorMessage = 'Fallo al conectar: $e. Revisa la URL del servidor.';
      notifyListeners();
      Future.delayed(const Duration(seconds: 10), _connectWebSocket);
    }
  }

  // Método para enviar un mensaje al servidor WebSocket (opcional, si tu app necesita enviar mensajes)
  void sendTestMessage(String message) {
    if (_channel != null && _isConnected) {
      debugPrint('📤 Enviando mensaje WebSocket: $message');
      _channel!.sink.add(message);
    } else {
      debugPrint('🚫 No se puede enviar mensaje, WebSocket no conectado.');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close(); // Cierra la conexión WebSocket al disponer el provider
    super.dispose();
  }
}