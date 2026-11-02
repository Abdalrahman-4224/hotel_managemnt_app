import '../entities/task_item.dart';

/// What the app can do with tasks.
/// The real implementation is in data/repositories/tasks_repository_impl.dart.
abstract class TasksRepository {
  Future<List<TaskItem>> getTasks();
  Future<void> createTask(NewTask task);

  /// The assignee starts working on it.
  Future<void> start(TaskItem task);

  /// The assignee finished it.
  Future<void> complete(TaskItem task);
}
