import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/tasks_repository_impl.dart';
import '../../domain/entities/task_item.dart';

/// Loads all of the hotel's tasks; the screen splits them into inbox / sent.
/// Every action calls the server, then reloads. Errors are rethrown.
class TasksController extends AsyncNotifier<List<TaskItem>> {
  @override
  Future<List<TaskItem>> build() {
    return ref.read(tasksRepositoryProvider).getTasks();
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(
      () => ref.read(tasksRepositoryProvider).getTasks(),
    );
  }

  Future<void> create(NewTask task) async {
    await ref.read(tasksRepositoryProvider).createTask(task);
    await refresh();
  }

  Future<void> start(TaskItem task) async {
    await ref.read(tasksRepositoryProvider).start(task);
    await refresh();
  }

  Future<void> complete(TaskItem task) async {
    await ref.read(tasksRepositoryProvider).complete(task);
    await refresh();
  }
}

final tasksControllerProvider =
    AsyncNotifierProvider<TasksController, List<TaskItem>>(TasksController.new);
