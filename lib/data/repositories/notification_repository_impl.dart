import 'package:money_mind_mobile/domain/repositories/notification_repository.dart';
import 'package:money_mind_mobile/data/services/notification_service.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationService _service = NotificationService();

  @override
  Future<void> connect() => _service.connect();

  @override
  Future<void> disconnect() => _service.disconnect();

  @override
  Future<void> joinGroup(String groupName) => _service.joinGroup(groupName);

  @override
  Future<void> leaveGroup(String groupName) => _service.leaveGroup(groupName);

  @override
  Stream<Map<String, dynamic>> get notificationStream => _service.notificationStream;

  @override
  Future<void> sendTestMessage(String user, String message) => _service.sendTestMessage(user, message);

  @override
  void dispose() => _service.dispose();
}
