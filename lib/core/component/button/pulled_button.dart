import 'package:starter_app/core/component/image/p_image.dart';
import 'package:starter_app/core/component/text/p_text.dart';
import 'package:starter_app/core/data/assets_helper/app_svg_icon.dart';
import 'package:starter_app/core/data/constants/app_colors.dart';
import 'package:starter_app/core/global/enums/global_enum.dart';
import 'package:starter_app/core/global/state/base_state.dart';
import 'package:starter_app/core/services/localization/app_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

enum PullStart { left, right }

class PullToConfirmButton extends StatefulWidget {
  final double width;
  final double height;
  final String text;
  final TextStyle? textStyle;
  final Color backgroundColor;
  final Color handleColor;
  final VoidCallback onConfirmed;
  final PullStart start;
  final double threshold; // fraction of travel (0..1)
  final bool showCheck;
  final BaseState state;

  const PullToConfirmButton({
    super.key,
    required this.onConfirmed,
    this.width = 320,
    this.height = 64,
    this.text = 'pull_to_confirm',
    this.textStyle,
    this.backgroundColor = AppColors.primaryColor,
    this.handleColor = Colors.white,
    this.start = PullStart.right,
    this.showCheck = false,
    this.threshold = 0.5,
    required this.state,
  });

  @override
  PullToConfirmButtonState createState() => PullToConfirmButtonState();
}

class PullToConfirmButtonState extends State<PullToConfirmButton>
    with SingleTickerProviderStateMixin {
  // current drag offset of the handle; positive means moving from its start toward center-left
  // we will normalize it depending on start side.
  double _drag = 0.0;
  late double _maxDrag; // max travel distance
  bool _isConfirming = false;
  late AnimationController _snapController;
  late Animation<double> _snapAnim;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _snapAnim = CurvedAnimation(parent: _snapController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails d) {
    _snapController.stop();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    // depending on start side map delta to positive drag
    double delta = d.delta.dx;
    if (widget.start == PullStart.right) {
      // dragging left should increase drag (delta negative)
      _drag -= delta;
    } else {
      // start left: dragging right should increase drag
      _drag += delta;
    }

    // clamp
    if (_drag < 0) _drag = 0;
    if (_drag > _maxDrag) _drag = _maxDrag;
    setState(() {});
  }

  void _onDragEnd(DragEndDetails d) {
    final passed = _drag >= (_maxDrag * widget.threshold);

    if (passed) {
      // animate handle to end (full travel), fire callback, then snap back after a pause
      _snapController.reset();
      _snapController.forward();
      _snapAnim.addListener(_snapToEndAndFireIfNeeded);
    } else {
      // animate back to 0
      _animateBackTo(0.0);
    }
  }

  void _snapToEndAndFireIfNeeded() {
    final t = _snapAnim.value;
    // interpolate from current _drag to full _maxDrag
    final startDrag = _drag;
    final target = _maxDrag;
    setState(() {
      _drag = startDrag + (target - startDrag) * t;
    });

    if (_snapAnim.isCompleted) {
      // ensure callback fired once
      if (!_isConfirming) {
        _isConfirming = true;
        widget.onConfirmed();
      }
      // after short delay, animate back to 0 and reset state
      Future.delayed(const Duration(milliseconds: 400), () {
        _animateBackTo(0.0);
        _isConfirming = false;
      });
      _snapAnim.removeListener(_snapToEndAndFireIfNeeded);
    }
  }

  void _animateBackTo(double to) {
    final from = _drag;
    _snapController.reset();
    _snapController.duration = const Duration(milliseconds: 350);
    _snapAnim = CurvedAnimation(parent: _snapController, curve: Curves.easeOut);
    _snapAnim.addListener(() {
      final t = _snapAnim.value;
      setState(() {
        _drag = from + (to - from) * t;
      });
      if (_snapAnim.isCompleted) {
        _snapAnim.removeListener(() {});
      }
    });
    _snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final handleSize = widget.height - 12;
    // maximum travel is width - handle - padding
    _maxDrag = (widget.width - handleSize - 16).clamp(0.0, double.infinity);

    // compute handle position in pixels from left
    // if start is right: initial handle is at right edge. We compute left coordinate.
    double left;
    const double padding = 8.0;
    if (widget.start == PullStart.right) {
      // ensure symmetry with _maxDrag calculation
      final initialLeft = widget.width - handleSize - padding - 27;
      left = (initialLeft - _drag).clamp(
        padding,
        widget.width - handleSize - padding,
      );
    } else {
      const initialLeft = padding - 27;
      left = (initialLeft + _drag).clamp(
        padding,
        widget.width - handleSize - padding,
      );
    }

    // fraction of progress used to animate text opacity / arrow movement
    final progress = (_maxDrag == 0) ? 0.0 : (_drag / _maxDrag).clamp(0.0, 1.0);

    // choose arrow icon & rotation
    final arrowIcon = (widget.start == PullStart.right)
        ? AppSvgIcons.backLeft
        : AppSvgIcons.backRight;

    // text opacity fades as handle approaches center
    final textOpacity = (1.0 - (progress * 1.2)).clamp(0.0, 1.0);

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          // Background bar
          // if(widget.showCheck)
          Container(
            padding: EdgeInsets.only(
              right: AppLocalization.isArabic ? 70 : 0,
              left: AppLocalization.isArabic ? 0 : 70,
            ),
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
            // alignment: Alignment.center,
            child: Opacity(
              opacity: textOpacity,
              child: (widget.showCheck)
                  ? PText(title: widget.text, size: PSize.text16)
                  :
                    // widget.state is LoadingState?
                    widget.state is LoadingState
                  ? Padding(
                      padding: EdgeInsets.only(
                        left: context.locale.languageCode == 'ar' ? 0 : 40,
                        right: context.locale.languageCode == 'en' ? 0 : 40,
                      ),
                      // child: const CustomLoader(size: 25,),
                      child: Skeletonizer(
                        enabled: true,
                        textBoneBorderRadius: const TextBoneBorderRadius(
                          BorderRadius.zero,
                        ),
                        effect: ShimmerEffect(
                          baseColor: AppColors.primaryColor.withValues(
                            alpha: 0.4,
                          ),
                          highlightColor: Colors.grey.shade100,
                          duration: const Duration(milliseconds: 1600),
                        ),
                        child: const PText(
                          title: '.....................................',
                          fontColor: AppColors.inactiveButtonColor,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                  : PText(
                      title: widget.state is LoadingState
                          ? ''
                          : widget.text.tr(),
                      size: PSize.text16,
                    ),
            ),
          ),

          // subtle progress fill that grows as user drags
          if (widget.showCheck)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: widget.start == PullStart.right
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(widget.height / 2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Draggable handle
          if (widget.showCheck)
            Positioned(
              top: 8,
              left: left,
              child: GestureDetector(
                onHorizontalDragStart: _onDragStart,
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: handleSize - 5,
                  height: handleSize - 5,
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(4)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Transform.rotate(
                    // tiny rotation for a lively feel depending on progress
                    angle:
                        (widget.start == PullStart.right ? -0.1 : 0.1) *
                        progress,
                    child: PImage(source: arrowIcon),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
