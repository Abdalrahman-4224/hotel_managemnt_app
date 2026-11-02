import 'package:flutter/material.dart';

import '../../core/errors/app_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'nz_buttons.dart';

/// Centered text for an empty list or a failed first load, with an optional retry button.
class NzStateMessage extends StatelessWidget {
  const NzStateMessage({super.key, required this.text, this.onRetry});

  /// A load error, with a retry button.
  NzStateMessage.error(Object? error, {super.key, required this.onRetry})
    : text = errorText(error);

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppText.body(14.5, color: AppColors.inkMuted),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              NzPrimaryButton(
                label: 'إعادة المحاولة',
                height: 48,
                onPressed: onRetry!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Spinner / error / [child] for a screen whose data comes from an AsyncValue.
/// Keeps showing [child] while a refresh is running.
class NzAsyncBody extends StatelessWidget {
  const NzAsyncBody({
    super.key,
    required this.hasValue,
    required this.error,
    required this.onRetry,
    required this.child,
  });

  final bool hasValue;
  final Object? error;
  final VoidCallback onRetry;
  final Widget Function() child;

  @override
  Widget build(BuildContext context) {
    if (hasValue) return child();
    if (error != null) return NzStateMessage.error(error, onRetry: onRetry);
    return const Center(child: CircularProgressIndicator());
  }
}
