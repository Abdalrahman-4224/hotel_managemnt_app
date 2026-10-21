import 'package:flutter/material.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/tasks_local_data_source.dart';
import '../../domain/entities/task_item.dart';
import '../widgets/task_card.dart';
import '../widgets/task_sheets.dart';

enum _Box { inbox, sent }

/// Task inbox for the signed-in staff member: tasks sent to them, and
/// tasks they sent to others.
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  static const _me = TasksLocalDataSource.meId;
  var _tasks = const TasksLocalDataSource().getTasks();
  var _box = _Box.inbox;
  TaskStatus? _filter;

  List<TaskItem> _inBox(_Box b) => _tasks
      .where((t) => b == _Box.inbox ? t.toId == _me : t.fromId == _me)
      .toList();

  void _setStatus(TaskItem t, TaskStatus s) => setState(
    () => _tasks = [for (final x in _tasks) x.id == t.id ? x.withStatus(s) : x],
  );

  @override
  Widget build(BuildContext context) {
    final me = TasksLocalDataSource.people[_me]!;
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
                  me.initial,
                  size: 42,
                  fontSize: 16,
                  dark: true,
                ),
                subtitle: '${me.name} · مشرف صيانة',
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
                child: ListView(
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
            ],
          ),
          PositionedDirectional(
            end: 16,
            bottom: NzBottomNav.fabBottom(context),
            child: NzFloatingButton(
              label: 'مهمة جديدة',
              onPressed: () async {
                final t = await showNewTaskSheet(context, fromId: _me);
                if (t != null) {
                  setState(() {
                    _tasks = [t, ..._tasks];
                    _box = _Box.sent;
                    _filter = null;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(TaskItem t) {
    final inbox = _box == _Box.inbox;
    final other = TasksLocalDataSource.people[inbox ? t.fromId : t.toId];
    final canAct = inbox && t.status != TaskStatus.done;
    return TaskCard(
      task: t,
      personInitial: other?.initial ?? '؟',
      personLine: '${inbox ? 'من' : 'إلى'} ${other?.name ?? '—'}',
      actionLabel: canAct
          ? (t.status == TaskStatus.fresh ? 'استلام' : 'إتمام')
          : null,
      actionPrimary: t.status == TaskStatus.inProgress,
      onAction: () async {
        if (t.status == TaskStatus.fresh) {
          _setStatus(t, TaskStatus.inProgress);
        } else if (await showCompleteTaskSheet(context, t) == true) {
          _setStatus(t, TaskStatus.done);
        }
      },
    );
  }
}
