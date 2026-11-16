import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/assistant_reply.dart';
import '../controllers/assistant_controller.dart';
import '../widgets/chat_widgets.dart';

/// Chat with the hotel assistant: questions about this hotel's revenue,
/// occupancy, arrivals, debts, tasks and stock, answered from its own data.
class AssistantScreen extends ConsumerWidget {
  const AssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final turns = ref.watch(assistantControllerProvider);
    final chat = ref.read(assistantControllerProvider.notifier);
    final status = ref.watch(assistantStatusProvider).value;
    final busy = turns.isNotEmpty && turns.last.answer.phase.isPending;

    // A failed status check doesn't block the chat: the question itself will
    // report the real problem.
    final disabled = status != null && !status.enabled;
    final starting = status != null && !status.ready;
    final subtitle = switch (status) {
      _ when disabled => 'غير متاح',
      _ when busy => 'يجيب الآن…',
      _ when starting => 'يستعد…',
      AssistantStatus(waiting: final w) when w > 0 => '$w أسئلة في الانتظار',
      _ => 'من بيانات فندقك مباشرة',
    };

    return Scaffold(
      body: Column(
        children: [
          NzPageHeader(
            showBack: Navigator.of(context).canPop(),
            subtitle: subtitle,
            title: 'المساعد الذكي',
            actions: [
              NzIconButton(
                icon: LucideIcons.squarePen,
                tooltip: 'محادثة جديدة',
                onPressed: turns.isEmpty ? null : chat.newChat,
                iconColor: turns.isEmpty ? AppColors.chevron : AppColors.ink3,
              ),
            ],
          ),
          Expanded(
            child: disabled
                ? const NzStateMessage(
                    text: 'المساعد غير مفعّل على الخادم حالياً.',
                  )
                : turns.isEmpty
                ? AssistantWelcome(onAsk: chat.send)
                : _Conversation(
                    turns: turns,
                    slowStart: starting,
                    onRetry: chat.retry,
                  ),
          ),
          if (!disabled)
            AssistantComposer(busy: busy, onSend: chat.send, onStop: chat.stop),
        ],
      ),
    );
  }
}

class _Conversation extends StatelessWidget {
  const _Conversation({
    required this.turns,
    required this.slowStart,
    required this.onRetry,
  });

  final List<ChatTurn> turns;
  final bool slowStart;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    // Reversed, so the newest turn sits just above the composer and a
    // growing answer stays in view without any manual scrolling.
    return ListView.builder(
      reverse: true,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s16,
        AppSpacing.s20,
      ),
      itemCount: turns.length,
      itemBuilder: (context, i) {
        final index = turns.length - 1 - i;
        final turn = turns[index];
        final isLast = index == turns.length - 1;
        return Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UserBubble(turn.question),
              SizedBox(height: AppSpacing.s12),
              AnswerBubble(
                answer: turn.answer,
                slowStart: slowStart && isLast,
                onRetry: isLast ? onRetry : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
