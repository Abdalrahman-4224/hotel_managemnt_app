import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../authentication/domain/entities/permissions.dart';
import '../../../authentication/presentation/controllers/permissions_controller.dart';
import '../../../authentication/presentation/controllers/auth_controller.dart';
import '../../../rooms/presentation/controllers/floors_controller.dart';
import '../../../staff/presentation/controllers/staff_controller.dart';
import '../../domain/entities/task_item.dart';
import '../controllers/tasks_controller.dart';
import '../widgets/task_card.dart';
import '../widgets/task_sheets.dart';

enum _Box { inbox, sent }

/// Task inbox for the signed-in staff member: tasks sent to them, and
/// tasks they sent to others.
class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  var _tasks = const <TaskItem>[];
  int? _me;
  var _box = _Box.inbox;
  TaskStatus? _filter;

  List<TaskItem> _inBox(_Box b) => _tasks
      .where((t) => b == _Box.inbox ? t.toId == _me : t.fromId == _me)
      .toList();

  /// Runs a task action and shows the server's message if it fails.
  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      if (mounted) showNzToast(context, errorText(error));
    }
  }

  Future<void> _newTask() async {
    final staff = await ref.read(staffControllerProvider.future);
    final floors = await ref.read(floorsControllerProvider.future);
    if (!mounted) return;
    final people = [
      for (final s in staff)
        if (s.id != _me)
          TaskPerson(
            id: s.id,
            name: s.name,
            subtitle: '${s.role} · ${s.department}',
            departmentId: s.departmentId,
          ),
    ];
    final task = await showNewTaskSheet(
      context,
      people: people,
      floors: floors,
    );
    if (task == null) return;
    await _run(() async {
      await ref.read(tasksControllerProvider.notifier).create(task);
      setState(() {
        _box = _Box.sent;
        _filter = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(tasksControllerProvider);
    final can = ref.watch(canProvider);
    final me = ref.watch(authControllerProvider).user;
    _me = me?.id;
    _tasks = async.value ?? const [];
    final myName = me?.fullName ?? '';
    final box = _inBox(_box);
    final shown = box
        .where((t) => _filter == null || t.status == _filter)
        .toList();
    int open(_Box b) =>
        _inBox(b).where((t) => t.status != TaskStatus.done).length;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              NzPageHeader(
                showBack: Navigator.of(context).canPop(),
                leading: NzInitialAvatar(
                  myName.isEmpty ? '؟' : myName.substring(0, 1),
                  size: 42,
                  fontSize: 16,
                  dark: true,
                ),
                subtitle: '$myName · ${me?.roleName ?? ''}',
                title: 'المهام',
                bottomGap: 14,
                bottom: NzSegmented<_Box>(
                  selected: _box,
                  countAsBadge: true,
                  onChanged: (b) => setState(() {
                    _box = b;
                    _filter = null;
                  }),
                  segments: [
                    NzSegment(
                      _Box.inbox,
                      'واردة إليّ',
                      count: '${open(_Box.inbox)}',
                    ),
                    NzSegment(
                      _Box.sent,
                      'أرسلتها',
                      count: '${open(_Box.sent)}',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: NzAsyncBody(
                  hasValue: async.hasValue,
                  error: async.error,
                  onRetry: () =>
                      ref.read(tasksControllerProvider.notifier).refresh(),
                  child: () => RefreshIndicator(
                    onRefresh: () =>
                        ref.read(tasksControllerProvider.notifier).refresh(),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(
                        top: 14,
                        bottom: NzBottomNav.bodyPadding(context) + 76,
                      ),
                      children: [
                        NzPillScroller(
                          children: [
                            for (final f in <TaskStatus?>[
                              null,
                              ...TaskStatus.values,
                            ])
                              NzChoicePill(
                                label: f?.label ?? 'الكل',
                                count:
                                    '${box.where((t) => f == null || t.status == f).length}',
                                selected: _filter == f,
                                onTap: () => setState(() => _filter = f),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (shown.isEmpty) ...[
                                const SizedBox(height: 12),
                                NzDashedBox(
                                  child: Text(
                                    'لا مهام هنا.',
                                    textAlign: TextAlign.center,
                                    style: AppText.body(
                                      14,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                ),
                              ],
                              for (final t in shown) ...[
                                const SizedBox(height: 12),
                                _card(t),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (can.can(Permissions.taskCreate))
            PositionedDirectional(
              end: 16,
              bottom: NzBottomNav.fabBottom(context),
              child: NzFloatingButton(
                label: 'مهمة جديدة',
                onPressed: () => _run(_newTask),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(TaskItem t) {
    final inbox = _box == _Box.inbox;
    final other = inbox ? t.fromName : t.toName;
    final canAct =
        inbox &&
        t.status != TaskStatus.done &&
        ref.read(canProvider).can(Permissions.taskUpdate);
    return TaskCard(
      task: t,
      personInitial: other.isEmpty ? '؟' : other.substring(0, 1),
      personLine: '${inbox ? 'من' : 'إلى'} $other',
      actionLabel: canAct
          ? (t.status == TaskStatus.fresh ? 'استلام' : 'إتمام')
          : null,
      actionPrimary: t.status == TaskStatus.inProgress,
      onAction: () async {
        final controller = ref.read(tasksControllerProvider.notifier);
        if (t.status == TaskStatus.fresh) {
          await _run(() => controller.start(t));
        } else if (await showCompleteTaskSheet(context, t) == true) {
          await _run(() => controller.complete(t));
        }
      },
    );
  }
}
