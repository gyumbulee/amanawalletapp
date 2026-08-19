import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/global_providers.dart';
import '../../data/datasources/notification_api_service.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/notification_repository.dart';

final notificationApiServiceProvider = Provider<NotificationApiService>((ref) {
  return NotificationApiService(ref.watch(dioProvider));
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepositoryImpl(ref.watch(notificationApiServiceProvider));
});
