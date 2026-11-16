import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/assistant_reply.dart';
import '../controllers/assistant_controller.dart';
import 'assistant_cards.dart';

/// The server cuts questions at this length.
const assistantMaxQuestion = 500;

/// The assistant's mark: gold sparkles on ink.
class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({super.key, this.size = 30});

  final double size;

  @override
  Widget build(BuildContext context) {
    return NzIconTile(
      LucideIcons.sparkles,
      tone: NzIconTileTone.ink,
      size: size.r,
      radius: (size * .34).r,
      iconSize: (size * .5).r,
    );
  }
}

final _firstLetter = RegExp(r'[A-Za-z؀-ۿ]');

/// Left to right when the text starts with a Latin letter, so an English
/// question reads "How much…?" and not "?How much…".
TextDirection textDirectionOf(String text) {
  final letter = _firstLetter.firstMatch(text)?.group(0);
  return letter != null && RegExp('[A-Za-z]').hasMatch(letter)
      ? TextDirection.ltr
      : TextDirection.rtl;
}

/// The user's question, on the far side from the assistant.
class UserBubble extends StatelessWidget {
  const UserBubble(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(AppRadius.r20);
    return Align(
          alignment: AlignmentDirectional.centerEnd,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .78,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.s14,
                vertical: AppSpacing.s10,
              ),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadiusDirectional.only(
                  topStart: r,
                  topEnd: r,
                  bottomStart: r,
                  bottomEnd: Radius.circular(AppRadius.r8),
                ),
                boxShadow: AppShadows.card,
              ),
              child: Text(
                text,
                textDirection: textDirectionOf(text),
                style: AppText.body(14.5, color: AppColors.onInk, height: 1.55),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 260.ms)
        .slideY(
          begin: .25,
          duration: AppMotion.popIn,
          curve: AppMotion.easeOut,
        );
  }
}

/// The assistant's answer as it arrives: progress → numbers → sentence.
class AnswerBubble extends StatelessWidget {
  const AnswerBubble({
    super.key,
    required this.answer,
    this.slowStart = false,
    this.onRetry,
  });

  final AssistantAnswer answer;

  /// The model is still starting on the server: the first answer is slow.
  final bool slowStart;

  /// Only the latest answer can be asked again.
  final VoidCallback? onRetry;

  String get _progressLabel => switch (answer.phase) {
    ReplyPhase.fetching => 'يجلب البيانات…',
    ReplyPhase.writing => 'يكتب الجواب…',
    _ when slowStart => 'المساعد يستعد، قد يأخذ أول جواب دقيقة…',
    _ => 'يفكّر…',
  };

  @override
  Widget build(BuildContext context) {
    final a = answer;
    final waiting = a.phase.isPending && a.text.isEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssistantAvatar(),
        SizedBox(width: AppSpacing.s10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (a.period != null && a.card != null) ...[
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _PeriodPill(_periodLabel(a.period!)),
                ),
                SizedBox(height: AppSpacing.s8),
              ],
              if (a.card != null) ...[
                AssistantCardView(a.card!)
                    .animate()
                    .fadeIn(duration: 320.ms)
                    .slideY(
                      begin: .08,
                      duration: AppMotion.popIn,
                      curve: AppMotion.easeOut,
                    ),
                SizedBox(height: AppSpacing.s10),
              ],
              if (a.text.isNotEmpty)
                _SentenceBubble(
                  text: a.text,
                  lang: a.lang,
                  writing: a.phase == ReplyPhase.writing,
                ),
              if (waiting) _Progress(_progressLabel),
              if (a.phase == ReplyPhase.failed)
                _Notice(
                  icon: LucideIcons.circleAlert,
                  color: AppColors.danger,
                  text: a.error ?? 'حدث خطأ ما، حاول مرة أخرى',
                  onRetry: onRetry,
                ),
              if (a.phase == ReplyPhase.stopped)
                _Notice(
                  icon: LucideIcons.circleStop,
                  color: AppColors.inkMuted,
                  text: 'أوقفتَ الجواب.',
                  onRetry: onRetry,
                ),
            ],
          ),
        ),
        // Leaves the far side free, so answers don't read as the user's.
        SizedBox(width: AppSpacing.s20),
      ],
    );
  }
}

String _periodLabel(AssistantPeriod p) {
  final today = DateTime.now();
  if (p.isOneDay) {
    if (isSameDay(p.from, today)) return 'اليوم';
    if (isSameDay(p.from, today.add(const Duration(days: 1)))) return 'غداً';
    if (isSameDay(p.from, today.subtract(const Duration(days: 1)))) {
      return 'أمس';
    }
    return fmtDate(p.from);
  }
  // Within one year the year is said once: "1/11 – 15/11/2026".
  final from = p.from.year == p.to.year
      ? '${p.from.day}/${p.from.month}'
      : fmtDate(p.from);
  return '$from – ${fmtDate(p.to)}';
}

/// The dates an answer covers, above its card. Shrinks with an ellipsis
/// instead of overflowing on a narrow screen.
class _PeriodPill extends StatelessWidget {
  const _PeriodPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 24.r,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.s10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.lineStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.calendar, size: 12.r, color: AppColors.ink3),
          SizedBox(width: AppSpacing.s4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(
                11.5,
                weight: FontWeight.w500,
                color: AppColors.ink3,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SentenceBubble extends StatelessWidget {
  const _SentenceBubble({
    required this.text,
    required this.lang,
    required this.writing,
  });

  final String text;
  final AssistantLang lang;
  final bool writing;

  @override
  Widget build(BuildContext context) {
    final r = Radius.circular(AppRadius.r20);
    final style = AppText.body(14.5, height: 1.65);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.s14,
        vertical: AppSpacing.s10,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(AppRadius.r8),
          topEnd: r,
          bottomStart: r,
          bottomEnd: r,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: text),
            if (writing)
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: const _Caret(),
              ),
          ],
        ),
        // English answers read left to right inside the Arabic layout.
        textDirection: lang == AssistantLang.english
            ? TextDirection.ltr
            : TextDirection.rtl,
        style: style,
      ),
    );
  }
}

/// Blinking cursor at the end of a sentence still being written.
class _Caret extends StatelessWidget {
  const _Caret();

  @override
  Widget build(BuildContext context) {
    return Padding(
          padding: EdgeInsetsDirectional.only(start: AppSpacing.s3),
          child: Container(
            width: 2.r,
            height: 15.r,
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .fade(begin: 1, end: .1, duration: 520.ms);
  }
}

/// Three pulsing dots with what the assistant is doing right now.
class _Progress extends StatelessWidget {
  const _Progress(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.s14,
          vertical: AppSpacing.s10,
        ),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(AppRadius.r18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 3; i++)
              Container(
                    width: 6.r,
                    height: 6.r,
                    margin: EdgeInsetsDirectional.only(end: AppSpacing.s4),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  )
                  .animate(onPlay: (c) => c.repeat())
                  .fade(
                    begin: .25,
                    end: 1,
                    delay: (i * 160).ms,
                    duration: 360.ms,
                  )
                  .then()
                  .fade(begin: 1, end: .25, duration: 360.ms),
            SizedBox(width: AppSpacing.s6),
            // The label changes as the answer moves on; cross-fade it.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                label,
                key: ValueKey(label),
                style: AppText.body(13, color: AppColors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.text,
    this.onRetry,
  });

  final IconData icon;
  final Color color;
  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: color),
        SizedBox(width: AppSpacing.s6),
        Flexible(
          child: Text(text, style: AppText.body(13, color: color, height: 1.5)),
        ),
        if (onRetry != null)
          NzLinkButton(label: 'إعادة', fontSize: 13, onPressed: onRetry),
      ],
    );
  }
}

/// What the empty chat shows: what the assistant can do, and questions to tap.
class AssistantWelcome extends StatelessWidget {
  const AssistantWelcome({super.key, required this.onAsk});

  final ValueChanged<String> onAsk;

  static const _suggestions = <(IconData, String)>[
    (LucideIcons.trendingUp, 'شكد دخلنا هالشهر؟'),
    (LucideIcons.bedDouble, 'شكو غرف فارغة هسه؟'),
    (LucideIcons.logIn, 'منو واصل اليوم؟'),
    (LucideIcons.receipt, 'شكد الديون على النزلاء؟'),
    (LucideIcons.listChecks, 'شنو المهام المفتوحة؟'),
    (LucideIcons.package, 'شنو المواد الناقصة بالمخزن؟'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s32,
        AppSpacing.s16,
        AppSpacing.s16,
      ),
      children: [
        Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.r24),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x40B68235),
                      blurRadius: 40,
                      spreadRadius: -6,
                    ),
                  ],
                ),
                child: const AssistantAvatar(size: 68),
              ),
            )
            .animate()
            .fadeIn(duration: 400.ms)
            .scaleXY(
              begin: .85,
              duration: AppMotion.popIn,
              curve: AppMotion.easeOut,
            ),
        SizedBox(height: AppSpacing.s18),
        Text(
          'اسألني عن فندقك',
          textAlign: TextAlign.center,
          style: AppText.display(24),
        ),
        SizedBox(height: AppSpacing.s6),
        Text(
          'الإيرادات والمصروفات، الإشغال، الواصلون والمغادرون، الديون، المهام والمخزن.\nبالعراقي أو الفصحى أو الإنجليزي.',
          textAlign: TextAlign.center,
          style: AppText.body(13.5, color: AppColors.inkMuted, height: 1.7),
        ),
        SizedBox(height: AppSpacing.s24),
        const NzGroupLabel('جرّب أن تسأل'),
        SizedBox(height: AppSpacing.s10),
        for (var i = 0; i < _suggestions.length; i++)
          Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.s8),
                child: NzCard(
                  radius: AppRadius.r16,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.s12,
                    vertical: AppSpacing.s10,
                  ),
                  onTap: () => onAsk(_suggestions[i].$2),
                  child: Row(
                    children: [
                      NzIconTile(
                        _suggestions[i].$1,
                        size: 32.r,
                        radius: AppRadius.r10,
                        iconSize: 15.r,
                      ),
                      SizedBox(width: AppSpacing.s12),
                      Expanded(
                        child: Text(
                          _suggestions[i].$2,
                          style: AppText.body(14.5, weight: FontWeight.w500),
                        ),
                      ),
                      Icon(
                        LucideIcons.arrowUpLeft,
                        size: 16.r,
                        color: AppColors.inkFaint,
                      ),
                    ],
                  ),
                ),
              )
              .animate()
              .fadeIn(delay: (120 + i * 60).ms, duration: 300.ms)
              .slideY(
                begin: .2,
                delay: (120 + i * 60).ms,
                duration: AppMotion.popIn,
                curve: AppMotion.easeOut,
              ),
        SizedBox(height: AppSpacing.s12),
        Text(
          'الأرقام من قاعدة بيانات الفندق مباشرة، والمساعد للقراءة فقط.',
          textAlign: TextAlign.center,
          style: AppText.body(12, color: AppColors.inkFaint),
        ),
      ],
    );
  }
}

/// The question box at the bottom. While an answer is coming, the send
/// button becomes a stop button.
class AssistantComposer extends StatefulWidget {
  const AssistantComposer({
    super.key,
    required this.busy,
    required this.onSend,
    required this.onStop,
  });

  final bool busy;
  final ValueChanged<String> onSend;
  final VoidCallback onStop;

  @override
  State<AssistantComposer> createState() => _AssistantComposerState();
}

class _AssistantComposerState extends State<AssistantComposer> {
  final _text = TextEditingController();

  /// Follows what is typed, so an English question isn't laid out right to left.
  var _direction = TextDirection.rtl;

  @override
  void initState() {
    super.initState();
    _text.addListener(() {
      final direction = textDirectionOf(_text.text);
      if (direction != _direction) setState(() => _direction = direction);
    });
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final q = _text.text.trim();
    if (q.isEmpty || widget.busy) return;
    HapticFeedback.lightImpact();
    widget.onSend(q);
    _text.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s10,
        AppSpacing.s12,
        AppSpacing.s10,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: BoxConstraints(minHeight: 48.r),
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppRadius.r24),
                  border: Border.all(color: AppColors.lineStrong),
                ),
                alignment: AlignmentDirectional.centerStart,
                child: TextField(
                  controller: _text,
                  textDirection: _direction,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(assistantMaxQuestion),
                  ],
                  style: AppText.body(15, height: 1.5),
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration(
                    isCollapsed: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: AppSpacing.s12,
                    ),
                    hintText: 'اكتب سؤالك…',
                    hintStyle: AppText.body(15, color: AppColors.inkFaint),
                  ),
                ),
              ),
            ),
            SizedBox(width: AppSpacing.s8),
            ValueListenableBuilder(
              valueListenable: _text,
              builder: (context, value, _) => _SendButton(
                busy: widget.busy,
                enabled: widget.busy || value.text.trim().isNotEmpty,
                onTap: widget.busy ? widget.onStop : _send,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
    required this.busy,
    required this.enabled,
    required this.onTap,
  });

  final bool busy;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = 48.r;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : .4,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: busy ? AppColors.goldTint : AppColors.ink,
          shape: BoxShape.circle,
          border: busy ? Border.all(color: AppColors.goldBorder) : null,
          boxShadow: busy ? null : AppShadows.ink,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: Tooltip(
              message: busy ? 'إيقاف' : 'إرسال',
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  busy ? LucideIcons.square : LucideIcons.arrowUp,
                  key: ValueKey(busy),
                  size: busy ? 16.r : 20.r,
                  color: busy ? AppColors.goldDeep : AppColors.goldLight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
