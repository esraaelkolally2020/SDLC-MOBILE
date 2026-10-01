import 'package:flutter/material.dart';

import '../../data/assets_helper/app_svg_icon.dart';
import '../../data/constants/app_colors.dart';
import '../../data/constants/global_obj.dart';
import '../../global/enums/global_enum.dart';
import '../../global/global_func.dart';
import '../../services/localization/app_localization.dart';
import '../image/p_image.dart';

/// Overlay toast shown on top of the root navigator.
///
/// Only one toast is visible at a time; showing a new one replaces the
/// previous. Works without a [BuildContext] (uses [navigatorKey]).
class PToast {
  PToast._();

  static OverlayEntry? _overlayEntry;

  static void showToast({
    BuildContext? context,
    required String message,
    MessageType type = MessageType.success,
    Duration duration = const Duration(seconds: 2),
    ToastPosition position = ToastPosition.bottom,
  }) {
    final OverlayState? overlay = context != null
        ? Overlay.maybeOf(context, rootOverlay: true)
        : navigatorKey.currentState?.overlay;
    if (overlay == null) return;

    dismiss();

    final entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        type: type,
        duration: duration,
        position: position,
        onDismissed: dismiss,
      ),
    );
    _overlayEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}

class _ToastWidget extends StatefulWidget {
  const _ToastWidget({
    required this.message,
    required this.type,
    required this.duration,
    required this.position,
    required this.onDismissed,
  });

  final String message;
  final MessageType type;
  final Duration duration;
  final ToastPosition position;
  final VoidCallback onDismissed;

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _controller.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final position = widget.position;
    return Positioned(
      top: position == ToastPosition.center
          ? MediaQuery.sizeOf(context).height * 0.50
          : (position == ToastPosition.top
                ? MediaQuery.paddingOf(context).top + 16
                : null),
      bottom: position == ToastPosition.bottom
          ? MediaQuery.paddingOf(context).bottom + 16
          : null,
      left: 18,
      right: 18,
      child: FadeTransition(
        opacity: _controller,
        child: _ToastLayout(message: widget.message, type: widget.type),
      ),
    );
  }
}

class _ToastLayout extends StatelessWidget {
  const _ToastLayout({required this.message, required this.type});

  final String message;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: getColorByType(type),
          borderRadius: BorderRadius.circular(4),
          boxShadow: isDark
              ? null
              : const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: getColorTints(type),
              ),
              child: getIcon(type),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                textAlign: AppLocalization.isArabic
                    ? TextAlign.right
                    : TextAlign.left,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontSize: 14, color: AppColors.whiteColor),
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

Color getColorByType(MessageType type) {
  return switch (type) {
    MessageType.success => AppColors.newSuccessColor,
    MessageType.error => AppColors.newErrorColor,
    MessageType.warning => AppColors.newWarningColor,
    MessageType.info => Colors.black54,
  };
}

Color getColorTints(MessageType type) {
  return switch (type) {
    MessageType.success => AppColors.newSuccessTintColor,
    MessageType.error => AppColors.newErrorTintColor,
    MessageType.warning => AppColors.newWarningTintColor,
    MessageType.info => Colors.black54,
  };
}

Widget getIcon(MessageType type) {
  return switch (type) {
    MessageType.error => const PImage(source: AppSvgIcons.error),
    MessageType.warning => const PImage(source: AppSvgIcons.warning),
    _ => const PImage(source: AppSvgIcons.success),
  };
}
