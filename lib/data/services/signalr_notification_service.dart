// lib/data/services/signalr_notification_service.dart

import 'dart:async'; // Necesario para StreamController y StreamSubscription
import 'dart:developer'; // Para usar log en depuración

import 'package:signalr_netcore/signalr_client.dart'; // Importa la librería SignalR
import 'package:money_mind_mobile/domain/repositories/notification_repository.dart'; // Importa la interfaz del repositorio
import 'package:money_mind_mobile/utils/constants.dart'; // Importa ApiConstants para la URL del hub

/// Implementación concreta de `NotificationRepository` utilizando `signalr_netcore`.
/// Gestiona la conexión y la recepción de notificaciones en tiempo real desde el backend.
class SignalRNotificationService implements NotificationRepository {
  HubConnection? _hubConnection; // Instancia de la conexión del hub de SignalR
  
  // StreamController para emitir las notificaciones recibidas a los oyentes.
  // Es un 'broadcast' para permitir múltiples oyentes.
  final StreamController<Map<String, dynamic>> _notificationController =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Getter que expone el stream de notificaciones para que la capa de dominio/presentación pueda escucharlo.
  @override
  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationController.stream;

  /// Establece y abre la conexión con el hub de SignalR.
  ///
  /// Si ya está conectado, simplemente registra un mensaje.
  /// Configura el manejo de cierre de conexión y escucha el método 'ReceiveNotification'
  /// del hub para procesar las notificaciones entrantes.
  @override
  Future<void> connect() async {
    // Si ya hay una conexión y está en estado 'Connected', no hacer nada.
    if (_hubConnection != null &&
        _hubConnection!.state == HubConnectionState.Connected) {
      log('SignalR: Ya conectado.');
      return;
    }

    // Construye la URL completa al hub de notificaciones.
    // Asegúrate que tu URL base (ApiConstants.baseUrl) no termine en '/'
    // y que el nombre del hub ('notificationHub') no empiece con '/'.
    // Ejemplo: 'http://192.168.1.9:5294/notificationHub'
    final String hubUrl = '${ApiConstants.baseUrl}/notificationHub';

    log('SignalR: Intentando conectar a $hubUrl...'); // LOG ADICIONAL
    _hubConnection = HubConnectionBuilder().withUrl(hubUrl).build();

    // Configura un callback para cuando la conexión se cierre (ej. por un error de red).
    _hubConnection!.onclose(({Exception? error}) {
      log('SignalR: Conexión cerrada. Error: $error. Estado final: ${_hubConnection?.state}'); // LOG ADICIONAL
      _notificationController.addError('Conexión perdida: $error'); // Emite el error al stream.
    });

    // Configura un callback para escuchar los cambios de estado del hub.
    // Esto es muy útil para depurar el ciclo de vida de la conexión.
    _hubConnection!.onreconnecting(({Exception? error}) {
      log('SignalR: Reconectando... Error: $error'); // LOG ADICIONAL
    });

    _hubConnection!.onreconnected(({String? connectionId}) {
      log('SignalR: Reconectado! Connection ID: $connectionId'); // LOG ADICIONAL
      // Considera volver a unirte a los grupos aquí si es necesario
      // Puedes obtener el userId desde un AuthProvider aquí si no lo tienes globalmente
      // final authProvider = Provider.of<AuthProvider>(context, listen: false); // No se puede hacer aquí directamente
      // if (authProvider.currentUser?.id != null) {
      //   joinGroup(authProvider.currentUser!.id.toString());
      // }
    });


    // Configura un callback para escuchar el método 'ReceiveNotification' del hub.
    // Este método es invocado desde el backend cuando se envía una notificación.
    _hubConnection!.on('ReceiveNotification', (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final dynamic rawData = arguments[0];
        if (rawData is Map) {
          final Map<String, dynamic> notificationData =
              Map<String, dynamic>.from(rawData);
          log('SignalR: Notificación recibida: $notificationData'); // LOG EXISTENTE
          _notificationController.add(notificationData);
        } else {
          log('SignalR: Notificación recibida en formato inesperado: $rawData'); // LOG EXISTENTE
        }
      } else {
        log('SignalR: Notificación recibida sin argumentos.'); // LOG ADICIONAL
      }
    });

    try {
      // Inicia la conexión con el hub.
      await _hubConnection!.start();
      log('SignalR: Conectado a $hubUrl. ID de Conexión: ${_hubConnection?.connectionId}'); // LOG ADICIONAL
    } catch (e) {
      // Maneja errores durante el intento de conexión.
      log('SignalR: Error al conectar: $e'); // LOG EXISTENTE
      _notificationController.addError('Error al conectar: $e'); // Emite el error al stream.
      rethrow; // Relanza la excepción para que el llamador la maneje si es necesario.
    }
  }

  /// Cierra la conexión con el hub de SignalR.
  @override
  Future<void> disconnect() async {
    if (_hubConnection != null &&
        _hubConnection!.state != HubConnectionState.Disconnected) {
      try {
        await _hubConnection!.stop();
        log('SignalR: Desconectado. Estado final: ${_hubConnection?.state}'); // LOG ADICIONAL
      } catch (e) {
        log('SignalR: Error al desconectar: $e'); // LOG EXISTENTE
      }
    } else {
      log('SignalR: No hay conexión activa para desconectar.'); // LOG ADICIONAL
    }
  }

  /// Invoca el método 'JoinGroup' en el hub de SignalR para unirse a un grupo específico.
  /// Útil para notificaciones dirigidas a usuarios o sesiones específicas.
  @override
  Future<void> joinGroup(String groupName) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      log('SignalR: Intentando unirse al grupo: $groupName'); // LOG ADICIONAL
      try {
        await _hubConnection!.invoke('JoinGroup', args: [groupName]);
        log('SignalR: Unido exitosamente al grupo: $groupName'); // LOG ADICIONAL
      } catch (e) {
        log('SignalR: Error al unirse al grupo $groupName: $e'); // LOG EXISTENTE
      }
    } else {
      log('SignalR: No conectado, no se puede unir al grupo $groupName. Estado actual: ${_hubConnection?.state}'); // LOG ADICIONAL
    }
  }

  /// Invoca el método 'LeaveGroup' en el hub de SignalR para abandonar un grupo específico.
  @override
  Future<void> leaveGroup(String groupName) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      log('SignalR: Intentando abandonar el grupo: $groupName'); // LOG ADICIONAL
      try {
        await _hubConnection!.invoke('LeaveGroup', args: [groupName]);
        log('SignalR: Abandonado exitosamente el grupo: $groupName'); // LOG ADICIONAL
      } catch (e) {
        log('SignalR: Error al abandonar el grupo $groupName: $e'); // LOG EXISTENTE
      }
    } else {
      log('SignalR: No conectado, no se puede abandonar el grupo $groupName.'); // LOG EXISTENTE
    }
  }

  /// Envía un mensaje de prueba al hub de SignalR.
  /// (Asumiendo que tu hub tiene un método 'SendMessage' para propósitos de prueba).
  @override
  Future<void> sendTestMessage(String user, String message) async {
    if (_hubConnection?.state == HubConnectionState.Connected) {
      log('SignalR: Intentando enviar mensaje de prueba a $user: "$message"'); // LOG ADICIONAL
      try {
        await _hubConnection!.invoke('SendMessage', args: [user, message]);
        log('SignalR: Mensaje de prueba enviado a $user: $message'); // LOG EXISTENTE
      } catch (e) {
        log('SignalR: Error al enviar mensaje de prueba: $e'); // LOG EXISTENTE
      }
    } else {
      log('SignalR: No conectado, no se puede enviar mensaje de prueba. Estado actual: ${_hubConnection?.state}'); // LOG ADICIONAL
    }
  }

  /// Libera los recursos del servicio.
  ///
  /// Cierra el `StreamController` y se asegura de que la conexión de SignalR
  /// se desconecte correctamente.
  @override
  void dispose() {
    _notificationController.close(); // Cierra el stream para evitar fugas de memoria.
    disconnect(); // Desconecta el hub de SignalR.
    log('SignalR: Servicio de notificación desechado.'); // LOG EXISTENTE
  }
}
