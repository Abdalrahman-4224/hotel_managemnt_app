import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../data/data_sources/tasks_local_data_source.dart';
import '../../domain/entities/task_item.dart';

/// Confirms finishing a task. Resolves to `true` when confirmed.
Future<bool?> showCompleteTaskSheet(BuildContext context, TaskItem t) {
  return showNzSheet<bool>(
    context,
    padding: const EdgeInsets.fromLTRB(18, 10, 18, 32),
    builder: (ctx) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const NzSheetTitle('إتمام المهمة'),
        const SizedBox(height: 14),
        Text(
          t.location.isEmpty ? t.title : '${t.title} · ${t.location}',
          style: AppText.body(14, color: AppColors.inkMuted),
        ),
        const SizedBox(height: 14),
        const NzTextField(
          label: 'ملاحظة الإنجاز (اختيارية)',
          hint: 'مثال: استُبدل الصنبور بالكامل',
          height: 92,
          maxLines: 4,
        ),
        const SizedBox(height: 14),
        NzPrimaryButton(
          label: 'تأكيد الإتمام',
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
}

/// Form state for a new task, shared by the sheet's body and footer.
class _NewTaskDraft extends ChangeNotifier {
  var type = TaskType.maintenance;
  var urgent = false;
  String? room;
  String? to;
  String? error;
  var mapOpen = false;
  final title = TextEditingController();

  void update(VoidCallback change) {
    change();
    notifyListeners();
  }

  /// Validates and builds the task, or flags the first missing field.
  TaskItem? build(String fromId) {
    if (title.text.trim().isEmpty) {
      update(() => error = 'title');
      return null;
    }
    if (to == null) {
      update(() => error = 'to');
      return null;
    }
    return TaskItem(
      id: 't${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      title: title.text.trim(),
      location: room == null ? '' : 'غرفة $room',
      fromId: fromId,
      toId: to!,
      status: TaskStatus.fresh,
      urgent: urgent,
      at: 'الآن',
    );
  }

  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }
}

/// Form for a new task. Resolves to the created task, or null.
Future<TaskItem?> showNewTaskSheet(
  BuildContext context, {
  required String fromId,
}) {
  final d = _NewTaskDraft();
  return showNzTallSheet<TaskItem>(
    context,
    heightFactor: .9,
    header: (ctx) => Text('مهمة جديدة', style: AppText.display(21)),
    body: (ctx) => ListenableBuilder(
      listenable: d,
      builder: (ctx, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Label('نوع المهمة'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in TaskType.values)
                NzChoicePill(
                  label: t.label,
                  selected: d.type == t,
                  onTap: () => d.update(() => d.type = t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          NzTextField(
            label: 'عنوان المهمة',
            hint: 'تسريب ماء في الحمّام',
            controller: d.title,
            error: d.error == 'title',
            style: AppText.body(16),
            onChanged: (_) {
              if (d.error != null) d.update(() => d.error = null);
            },
          ),
          if (d.error == 'title') ...[
            const SizedBox(height: 7),
            const _Error('اكتب عنواناً للمهمة.'),
          ],
          const SizedBox(height: 16),
          const _Label('الغرفة (اختياري)'),
          const SizedBox(height: 7),
          _RoomPicker(draft: d),
          const SizedBox(height: 16),
          const NzTextField(
            label: 'التفاصيل (اختياري)',
            height: 80,
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          const _Label('الأولوية'),
          const SizedBox(height: 7),
          NzSegmented<bool>(
            selected: d.urgent,
            onChanged: (v) => d.update(() => d.urgent = v),
            segments: const [
              NzSegment(false, 'عادية'),
              NzSegment(true, 'عاجلة'),
            ],
          ),
          const SizedBox(height: 16),
          const _Label('إرسال إلى · فنيو الصيانة'),
          for (final id in TasksLocalDataSource.assignees) ...[
            const SizedBox(height: 8),
            _PersonOption(
              person: TasksLocalDataSource.people[id]!,
              selected: d.to == id,
              onTap: () => d.update(() {
                d.to = id;
                d.error = null;
              }),
            ),
          ],
          if (d.error == 'to') ...[
            const SizedBox(height: 8),
            const _Error('اختر الشخص الذي تُرسل إليه المهمة.'),
          ],
        ],
      ),
    ),
    footer: (ctx) => Row(
      children: [
        Expanded(
          child: NzOutlineButton(
            label: 'إلغاء',
            height: 54,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: NzPrimaryButton(
            label: 'إرسال المهمة',
            icon: LucideIcons.send,
            onPressed: () {
              final task = d.build(fromId);
              if (task != null) Navigator.of(ctx).pop(task);
            },
          ),
        ),
      ],
    ),
  ).whenComplete(() => Future.delayed(const Duration(seconds: 1), d.dispose));
}

/// Collapsible room map for picking the task's room.
class _RoomPicker extends StatelessWidget {
  const _RoomPicker({required this.draft});

  final _NewTaskDraft draft;

  @override
  Widget build(BuildContext context) {
    final d = draft;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onTap: () => d.update(() => d.mapOpen = !d.mapOpen),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.lineStrong),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.grid2x2,
                  size: 18,
                  color: AppColors.goldDeep,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    d.room == null ? 'اختر من خريطة الغرف' : 'غرفة ${d.room}',
                    style: AppText.body(15, weight: FontWeight.w500),
                  ),
                ),
                AnimatedRotation(
                  turns: d.mapOpen ? .5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    LucideIcons.chevronDown,
                    size: 16,
                    color: AppColors.inkFaint,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (d.mapOpen) ...[
          const SizedBox(height: 7),
          NzCard(
                radius: 18,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final (i, (name, rooms))
                        in TasksLocalDataSource.roomMap.indexed) ...[
                      if (i > 0) const SizedBox(height: 10),
                      Text(
                        name,
                        style: AppText.body(12.5, color: AppColors.inkMuted),
                      ),
                      const SizedBox(height: 6),
                      NzGrid(
                        columns: 6,
                        spacing: 6,
                        children: [
                          for (final no in rooms)
                            _RoomChip(
                              number: no,
                              selected: d.room == no,
                              onTap: () => d.update(() {
                                d.room = d.room == no ? null : no;
                                d.mapOpen = false;
                              }),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              )
              .animate()
              .fadeIn(duration: 300.ms)
              .moveY(begin: 8, end: 0, duration: 300.ms),
        ],
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.body(13, color: AppColors.inkMuted));
}

class _Error extends StatelessWidget {
  const _Error(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppText.body(13, color: AppColors.goldDeep));
}

class _RoomChip extends StatelessWidget {
  const _RoomChip({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final String number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: selected ? AppColors.goldTint : AppColors.paper,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.goldDeep : const Color(0x1A1C1B19),
            width: selected ? 1.5 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          number,
          style: AppText.num(
            13,
            color: selected ? AppColors.goldDarkest : AppColors.ink,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class _PersonOption extends StatelessWidget {
  const _PersonOption({
    required this.person,
    required this.selected,
    required this.onTap,
  });

  final TaskPerson person;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return NzOptionTile(
      selected: selected,
      onTap: onTap,
      minHeight: 60,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          NzInitialAvatar(person.initial, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  person.name,
                  style: AppText.body(15, weight: FontWeight.w500),
                ),
                Text(
                  person.online ? 'متصل الآن' : 'غير متصل',
                  style: AppText.body(12.5, color: AppColors.inkMuted),
                ),
              ],
            ),
          ),
          NzRadioDot(selected: selected),
        ],
      ),
    );
  }
}
