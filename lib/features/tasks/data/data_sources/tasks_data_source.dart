import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_providers.dart';

class TasksDataSource {
  final ApiClient apiClient;

  TasksDataSource(this.apiClient);

  /// Tasks with room, floor and people names, newest first.
  Future<List<Map<String, dynamic>>> fetchTasks() async {
    final data = await apiClient.get('/tasks');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createTask(Map<String, dynamic> body) async {
    await apiClient.post('/tasks', data: body);
  }

  /// Only the fields sent change, e.g. {'status': 'InProgress'}.
  Future<void> updateTask(int taskId, Map<String, dynamic> body) async {
    await apiClient.put('/tasks/$taskId', data: body);
  }
}

final tasksDataSourceProvider = Provider<TasksDataSource>((ref) {
  return TasksDataSource(ref.watch(apiClientProvider));
});
