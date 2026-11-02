/// Task types the server accepts (tasks.task_type).
enum TaskType { maintenance, cleaning, generalService }

extension TaskTypeLabel on TaskType {
  String get label => switch (this) {
    TaskType.maintenance => 'صيانة',
    TaskType.cleaning => 'تنظيف',
    TaskType.generalService => 'خدمة عامة',
  };
}

enum TaskStatus { fresh, inProgress, done }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
    TaskStatus.fresh => 'جديدة',
    TaskStatus.inProgress => 'قيد التنفيذ',
    TaskStatus.done => 'منجزة',
  };
}

/// Someone a task can be sent to.
class TaskPerson {
  const TaskPerson({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.departmentId,
  });

  final int id;
  final String name;

  /// Role and department, shown under the name.
  final String subtitle;
  final int? departmentId;

  String get initial => name.isEmpty ? '؟' : name.substring(0, 1);
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.status,
    required this.at,
    this.urgent = false,
  });

  final int id;
  final TaskType type;
  final String title;
  final String location;
  final int? fromId;
  final String fromName;
  final int? toId;
  final String toName;
  final TaskStatus status;

  /// When it was sent, e.g. "09:40" or "19/8 09:40".
  final String at;
  final bool urgent;
}

/// What the new-task form collects.
class NewTask {
  const NewTask({
    required this.type,
    required this.description,
    required this.roomId,
    required this.floorId,
    required this.assignee,
    required this.urgent,
  });

  final TaskType type;
  final String description;
  final int? roomId;
  final int? floorId;
  final TaskPerson assignee;
  final bool urgent;
}
