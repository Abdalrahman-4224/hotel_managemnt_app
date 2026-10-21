enum TaskType { maintenance, cleaning, guestRequest, inspection, admin }

extension TaskTypeLabel on TaskType {
  String get label => switch (this) {
    TaskType.maintenance => 'صيانة',
    TaskType.cleaning => 'تنظيف',
    TaskType.guestRequest => 'طلب نزيل',
    TaskType.inspection => 'فحص دوري',
    TaskType.admin => 'متابعة إدارية',
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

class TaskPerson {
  const TaskPerson(this.id, this.name, this.initial, {this.online = false});

  final String id;
  final String name;
  final String initial;
  final bool online;
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.type,
    required this.title,
    required this.location,
    required this.fromId,
    required this.toId,
    required this.status,
    required this.at,
    this.urgent = false,
  });

  final String id;
  final TaskType type;
  final String title;
  final String location;
  final String fromId;
  final String toId;
  final TaskStatus status;
  final String at;
  final bool urgent;

  TaskItem withStatus(TaskStatus s) => TaskItem(
    id: id,
    type: type,
    title: title,
    location: location,
    fromId: fromId,
    toId: toId,
    status: s,
    at: at,
    urgent: urgent,
  );
}
