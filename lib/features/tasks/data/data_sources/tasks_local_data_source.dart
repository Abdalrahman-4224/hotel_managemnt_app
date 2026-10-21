import '../../domain/entities/task_item.dart';

/// Sample data from the design. Replace with an API data source.
class TasksLocalDataSource {
  const TasksLocalDataSource();

  /// The signed-in user (a maintenance supervisor in the design).
  static const meId = 'ahmad';

  static const people = {
    'khalid': TaskPerson('khalid', 'خالد السامرائي', 'خ'),
    'sara': TaskPerson('sara', 'سارة العبدلي', 'س'),
    'ahmad': TaskPerson('ahmad', 'أحمد الجابري', 'أ'),
    'hasan': TaskPerson('hasan', 'حسن الربيعي', 'ح', online: true),
    'ali': TaskPerson('ali', 'علي الزبيدي', 'ع'),
    'omar': TaskPerson('omar', 'عمر الدليمي', 'ع', online: true),
  };

  /// Technicians the user can assign work to.
  static const assignees = ['hasan', 'ali', 'omar'];

  static const roomMap = [
    (
      'الطابق الأول',
      [
        '101', '102', '103', '104', '105', '106', '107', '108', '109', //
        '110', '111', '112', '113', '114', '115', '116', '117', '118',
      ],
    ),
    ('الطابق الثاني', ['201', '202', '203', '204', '205', '206']),
    ('الطابق الثالث', ['301', '302', '303', '304', '305', '306']),
  ];

  List<TaskItem> getTasks() => const [
    TaskItem(
      id: 't1',
      type: TaskType.maintenance,
      title: 'تسريب ماء في حمّام الغرفة',
      location: 'غرفة 205',
      fromId: 'khalid',
      toId: 'ahmad',
      status: TaskStatus.fresh,
      urgent: true,
      at: '09:40',
    ),
    TaskItem(
      id: 't2',
      type: TaskType.inspection,
      title: 'فحص المصعد الرئيسي',
      location: 'المصعد',
      fromId: 'khalid',
      toId: 'ahmad',
      status: TaskStatus.inProgress,
      at: '08:05',
    ),
    TaskItem(
      id: 't3',
      type: TaskType.maintenance,
      title: 'إنارة الممر لا تعمل',
      location: 'الطابق الثاني',
      fromId: 'sara',
      toId: 'ahmad',
      status: TaskStatus.done,
      at: 'أمس 21:10',
    ),
    TaskItem(
      id: 't4',
      type: TaskType.maintenance,
      title: 'تبديل صنبور المغسلة',
      location: 'غرفة 102',
      fromId: 'ahmad',
      toId: 'hasan',
      status: TaskStatus.done,
      at: '10:20',
    ),
    TaskItem(
      id: 't5',
      type: TaskType.maintenance,
      title: 'مكيّف لا يبرّد',
      location: 'غرفة 304',
      fromId: 'ahmad',
      toId: 'ali',
      status: TaskStatus.fresh,
      at: '11:05',
    ),
    TaskItem(
      id: 't6',
      type: TaskType.maintenance,
      title: 'إصلاح قفل الباب',
      location: 'غرفة 110',
      fromId: 'ahmad',
      toId: 'hasan',
      status: TaskStatus.inProgress,
      urgent: true,
      at: '11:40',
    ),
  ];
}
