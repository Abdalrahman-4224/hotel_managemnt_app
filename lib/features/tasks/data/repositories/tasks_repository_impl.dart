import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/task_item.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../data_sources/tasks_data_source.dart';
import '../models/task_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  final TasksDataSource dataSource;

  TasksRepositoryImpl(this.dataSource);

  @override
  Future<List<TaskItem>> getTasks() async {
    final rows = await dataSource.fetchTasks();
    return rows.map(TaskModel.fromJson).toList();
  }

  @override
  Future<void> createTask(NewTask task) {
    return dataSource.createTask(TaskModel.newTaskToJson(task));
  }

  @override
  Future<void> start(TaskItem task) {
    return dataSource.updateTask(task.id, {
      'status': 'InProgress',
      'at_started': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> complete(TaskItem task) {
    return dataSource.updateTask(task.id, {
      'status': 'Completed',
      'at_completed': DateTime.now().toUtc().toIso8601String(),
    });
  }
}

final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  return TasksRepositoryImpl(ref.watch(tasksDataSourceProvider));
});
