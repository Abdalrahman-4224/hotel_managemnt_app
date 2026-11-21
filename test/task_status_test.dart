import 'package:flutter_test/flutter_test.dart';
import 'package:hotel_managemnt_app/features/tasks/data/models/task_model.dart';
import 'package:hotel_managemnt_app/features/tasks/domain/entities/task_item.dart';

void main() {
  group('a task status from the server', () {
    test('the states the app acts on', () {
      expect(TaskModel.statusFromJson('Pending'), TaskStatus.fresh);
      expect(TaskModel.statusFromJson('InProgress'), TaskStatus.inProgress);
      // The server's own extra state; the app treats it as in progress.
      expect(TaskModel.statusFromJson('Approved'), TaskStatus.inProgress);
      expect(TaskModel.statusFromJson('Completed'), TaskStatus.done);
    });

    test('a cancelled task is cancelled, not new', () {
      expect(TaskModel.statusFromJson('Cancelled'), TaskStatus.cancelled);
      expect(TaskModel.statusFromJson('Canceled'), TaskStatus.cancelled);
    });

    test('anything unknown is still shown as new', () {
      expect(TaskModel.statusFromJson(null), TaskStatus.fresh);
      expect(TaskModel.statusFromJson('Whatever'), TaskStatus.fresh);
    });

    test('nothing is left to do on a cancelled or finished task', () {
      expect(TaskStatus.cancelled.isClosed, isTrue);
      expect(TaskStatus.done.isClosed, isTrue);
      expect(TaskStatus.fresh.isClosed, isFalse);
      expect(TaskStatus.inProgress.isClosed, isFalse);
    });

    test('every state has Arabic wording', () {
      expect(TaskStatus.cancelled.label, 'ملغاة');
      for (final s in TaskStatus.values) {
        expect(s.label, isNotEmpty);
      }
    });
  });

  test('a cancelled task read from the server carries no buttons', () {
    final task = TaskModel.fromJson({
      'task_id': 12,
      'task_type': 'Cleaning',
      'description': 'تنظيف بعد الخروج\nالغرفة 101',
      'status': 'Cancelled',
      'room_number': '101',
      'created_at': DateTime.now().toIso8601String(),
    });
    expect(task.status, TaskStatus.cancelled);
    // What the screen reads to decide whether to offer استلام / إنجاز.
    expect(task.status.isClosed, isTrue);
    expect(task.title, 'تنظيف بعد الخروج');
  });
}
