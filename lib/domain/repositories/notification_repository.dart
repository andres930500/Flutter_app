// lib/domain/repositories/notification_repository.dart

import 'dart:async';

abstract class NotificationRepository {
  Future<void> connect();
  Future<void> disconnect();
  Future<void> joinGroup(String groupName);
  Future<void> leaveGroup(String groupName);
  Stream<Map<String, dynamic>> get notificationStream;
  Future<void> sendTestMessage(String user, String message);
  void dispose(); // ¡Asegúrate de que esta línea esté presente!
}