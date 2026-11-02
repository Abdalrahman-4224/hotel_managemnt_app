import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/json_parsers.dart';
import '../../domain/entities/task_item.dart';

/// Converts tasks between the app and GET/POST /tasks.
class TaskModel {
  const TaskModel._();

  static String typeToJson(TaskType type) => switch (type) {
    TaskType.maintenance => 'Maintenance',
    TaskType.cleaning => 'Cleaning',
    TaskType.generalService => 'GeneralService',
  };

  static TaskType typeFromJson(String? value) => switch (value) {
    'Cleaning' => TaskType.cleaning,
    'Maintenance' => TaskType.maintenance,
    _ => TaskType.generalService,
  };

  /// The server also has 'Approved'; the app shows it as in progress.
  static TaskStatus statusFromJson(String? value) => switch (value) {
    'Completed' => TaskStatus.done,
    'InProgress' || 'Approved' => TaskStatus.inProgress,
    _ => TaskStatus.fresh,
  };

  static TaskItem fromJson(Map<String, dynamic> json) {
    final room = json['room_number'];
    final floor = json['name_floor'];
    final sentAt = parseDate(json['created_at']);
    final today = DateTime.now();
    return TaskItem(
      id: parseInt(json['task_id'])!,
      type: typeFromJson(json['task_type']),
      // The first line is the title; the rest are details.
      title: (json['description'] ?? '').toString().split('\n').first,
      location: room != null ? 'غرفة $room' : (floor ?? ''),
      fromId: parseInt(json['created_by_user_id']),
      fromName: json['created_by_name'] ?? '—',
      toId: parseInt(json['assigned_to_user_id']),
      toName: json['assigned_to_name'] ?? '—',
      status: statusFromJson(json['status']),
      at: isSameDay(sentAt, today)
          ? fmtTime(sentAt)
          : '${sentAt?.day}/${sentAt?.month} ${fmtTime(sentAt)}',
      urgent: json['is_urgent'] == true,
    );
  }

  static Map<String, dynamic> newTaskToJson(NewTask task) {
    return {
      'task_type': typeToJson(task.type),
      'description': task.description,
      'room_id': task.roomId,
      'floor_id': task.floorId,
      'assigned_to_user_id': task.assignee.id,
      // The task belongs to the department of the person doing it.
      'department_id': task.assignee.departmentId,
      'status': 'Pending',
      'is_urgent': task.urgent,
    };
  }
}
