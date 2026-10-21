import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/widgets/widgets.dart';

/// Six single-digit boxes. Typing advances, backspace on an empty box goes
/// back, and pasting a code fills every box.
class OtpInput extends StatefulWidget {
  const OtpInput({super.key, required this.onChanged, this.length = 6});

  final int length;
  final ValueChanged<String> onChanged;

  @override
  State<OtpInput> createState() => OtpInputState();
}

class OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _ctrls = List.generate(
    widget.length,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _nodes = List.generate(widget.length, (i) {
    return FocusNode(
      onKeyEvent: (node, e) {
        if (e is KeyDownEvent &&
            e.logicalKey == LogicalKeyboardKey.backspace &&
            _ctrls[i].text.isEmpty &&
            i > 0) {
          _ctrls[i - 1].clear();
          _nodes[i - 1].requestFocus();
          _emit();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
    );
  });

  String get value => _ctrls.map((c) => c.text).join();

  void clear() {
    for (final c in _ctrls) {
      c.clear();
    }
    _emit();
    focusFirst();
  }

  void focusFirst() => _nodes.first.requestFocus();

  void _emit() {
    setState(() {});
    widget.onChanged(value);
  }

  void _put(int from, String digits) {
    var k = from;
    for (final ch in digits.split('')) {
      if (k >= widget.length) break;
      _ctrls[k++].text = ch;
    }
    _nodes[k.clamp(0, widget.length - 1)].requestFocus();
    _emit();
  }

  void _onChanged(int i, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      _ctrls[i].clear();
      _emit();
    } else if (digits.length >= widget.length) {
      // Paste or SMS autofill: spread the code from the first box.
      _put(0, digits);
    } else {
      // Typing over a filled box keeps only the newest digit.
      _put(i, digits.substring(digits.length - 1));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final firstEmpty = _ctrls.indexWhere((c) => c.text.isEmpty);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          for (var i = 0; i < widget.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _cell(i, firstEmpty)),
          ],
        ],
      ),
    );
  }

  Widget _cell(int i, int firstEmpty) {
    final filled = _ctrls[i].text.isNotEmpty;
    final active = i == firstEmpty;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 58,
      decoration: BoxDecoration(
        color: filled
            ? AppColors.goldTint
            : active
            ? Colors.white
            : AppColors.paper,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: filled
              ? AppColors.goldDeep
              : active
              ? AppColors.gold
              : AppColors.lineStrong,
          width: filled || active ? 1.5 : 1,
        ),
        boxShadow: active && !filled
            ? const [BoxShadow(color: Color(0x1FB68235), spreadRadius: 4)]
            : null,
      ),
      alignment: Alignment.center,
      child: Semantics(
        label: 'الرقم ${i + 1}',
        child: TextField(
          controller: _ctrls[i],
          focusNode: _nodes[i],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          autofillHints: i == 0 ? const [AutofillHints.oneTimeCode] : null,
          cursorColor: AppColors.gold,
          style: AppText.num(23, height: 1),
          decoration: const InputDecoration.collapsed(hintText: ''),
          onChanged: (v) => _onChanged(i, v),
        ),
      ),
    );
  }
}
