import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Labelled input with the design's 16px rounded hairline box.
/// The border turns gold while focused.
class NzTextField extends StatefulWidget {
  const NzTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.style,
    this.height = 52,
    this.radius = 16,
    this.prefix,
    this.autofillHints,
    this.maxLines = 1,
    this.error = false,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextStyle? style;
  final double height;
  final double radius;

  /// Widget glued to the start of the field (e.g. the +964 country box).
  final Widget? prefix;
  final Iterable<String>? autofillHints;
  final int maxLines;
  final bool error;

  @override
  State<NzTextField> createState() => _NzTextFieldState();
}

class _NzTextFieldState extends State<NzTextField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    final style = widget.style ?? AppText.body(15);
    final multiline = widget.maxLines > 1;
    final field = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      // Single-line fields have a fixed height; multi-line ones grow.
      height: multiline ? null : widget.height,
      constraints: BoxConstraints(minHeight: widget.height),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(
          color: widget.error
              ? AppColors.goldDeep
              : focused
              ? AppColors.gold
              : AppColors.lineStrong,
          width: focused || widget.error ? 1.5 : 1,
        ),
        boxShadow: focused
            ? const [BoxShadow(color: Color(0x1FB68235), spreadRadius: 4)]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: multiline
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.stretch,
        children: [
          if (widget.prefix != null) widget.prefix!,
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: multiline ? 12 : 0,
              ),
              child: Align(
                alignment: multiline
                    ? AlignmentDirectional.topStart
                    : AlignmentDirectional.centerStart,
                child: TextField(
                  focusNode: _focus,
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  keyboardType: widget.keyboardType,
                  inputFormatters: widget.inputFormatters,
                  textDirection: widget.textDirection,
                  textAlign: widget.textAlign,
                  autofillHints: widget.autofillHints,
                  maxLines: widget.maxLines,
                  minLines: 1,
                  style: style,
                  cursorColor: AppColors.gold,
                  decoration: InputDecoration.collapsed(
                    hintText: widget.hint,
                    hintStyle: style.copyWith(color: AppColors.inkFaint),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    if (widget.label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label!, style: AppText.body(13, color: AppColors.inkMuted)),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}
