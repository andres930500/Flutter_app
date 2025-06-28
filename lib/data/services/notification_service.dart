import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:signalr_netcore/signalr_client.dart';

class NotificationService {
  HubConnection? _hubConnection;

  // Controlador del stream para escuchar notificaciones
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();

  // Stream que puedes escuchar desde cualquier parte de la app
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;

  // ✅ Conectar al servidor SignalR
  Future<void> connect() async {
    // ⚠️ Aquí debe ir la URL REAL del backend + "/notificationHub"
    final url = "http://192.168.1.9:5294/notificationHub";

    _hubConnection = HubConnectionBuilder()
        .withUrl(url)
        .withAutomaticReconnect()
        .build();

    // Escuchar evento de notificación desde el servidor
    _hubConnection!.on("ReceiveNotification", (args) {
      if (args != null && args.isNotEmpty) {
        final raw = args[0];

        if (raw is Map<String, dynamic>) {
          _notificationController.add(raw);
        } else if (raw is String) {
          try {
            final parsed = jsonDecode(raw);
            if (parsed is Map<String, dynamic>) {
              _notificationController.add(parsed);
            }
          } catch (e) {
            log("❌ Error al parsear la notificación: $e");
          }
        } else {
          log("❌ Tipo de dato no reconocido: ${raw.runtimeType}");
        }
      }
    });

    // Iniciar conexión
    await _hubConnection!.start();
    log("✅ Conectado a SignalR");
  }

  // Desconectar manualmente
  Future<void> disconnect() async {
    await _hubConnection?.stop();
    log("🔌 Desconectado de SignalR");
  }

  // Unirse a un grupo (normalmente el ID del usuario)
  Future<void> joinGroup(String groupName) async {
    await _hubConnection?.invoke("JoinGroup", args: [groupName]);
    log("✅ Unido al grupo $groupName");
  }

  // Salir de un grupo
  Future<void> leaveGroup(String groupName) async {
    await _hubConnection?.invoke("LeaveGroup", args: [groupName]);
    log("🚪 Saliste del grupo $groupName");
  }

  // Enviar mensaje de prueba
  Future<void> sendTestMessage(String user, String message) async {
    await _hubConnection?.invoke("SendMessageToUser", args: [user, message]);
  }

  // Destruir conexión y cerrar stream
  void dispose() {
    _notificationController.close();
    _hubConnection?.stop();
  }
}
