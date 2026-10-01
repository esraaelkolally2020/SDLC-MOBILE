import 'package:starter_app/core/component/custom_toast/p_toast.dart';
import 'package:starter_app/core/services/log/app_log.dart';
import 'package:starter_app/core/services/network/response/api_response.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/cubit/safe_cubit.dart';
import 'package:starter_app/core/data/constants/app_colors.dart';
import 'package:starter_app/core/global/enums/global_enum.dart';
import 'package:starter_app/core/global/global_func.dart';

import '../../global/state/base_state.dart';
import '../custom_loader/custom_loader.dart';
import '../text/p_text.dart';

class ButtonWidget extends StatelessWidget {
  final GestureTapCallback? onPressed;
  final String? title;
  final FontWeight? fontWeight;
  final PSize? size;
  final List<String>? dropDown;
  final double? borderRadius;
  final MainAxisSize? mainAxisSize;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final Widget? icon;
  final Color? textColor;
  final bool isFitWidth;
  final bool isLeftIcon;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final Color? fillColor;
  final Color? borderColor;

  const ButtonWidget({
    super.key,
    required this.onPressed,
    this.size,
    this.isFitWidth = false,
    this.isLeftIcon = false,
    this.fontWeight,
    this.borderColor,
    this.borderRadiusGeometry,
    this.mainAxisSize,
    this.title,
    this.icon,
    this.dropDown,
    this.textColor,
    this.fillColor,
    this.borderRadius,
    this.padding,

    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,

      onHover: (m) {},
      style: ElevatedButton.styleFrom(
        backgroundColor: fillColor,
        disabledBackgroundColor: fillColor ?? AppColors.inactiveButtonColor,
        shape: RoundedRectangleBorder(
          borderRadius:
              borderRadiusGeometry ?? BorderRadius.circular(borderRadius ?? 4),
          side: BorderSide(
            color: borderColor != null
                ? borderColor!
                : fillColor != null
                ? fillColor!
                : AppColors.primaryColor,
          ),
        ),
        elevation: elevation,
        padding: padding,
        minimumSize: isFitWidth
            ? const Size.fromHeight(48)
            : const Size(60, 48),
      ),

      child: isLeftIcon
          ? Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (title != null)
                  Flexible(
                    fit: FlexFit.loose,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: PText(
                        title: title!.tr(),
                        size: size ?? PSize.text18,

                        fontColor: textColor ?? AppColors.whiteColor,
                        fontWeight: fontWeight ?? FontWeight.w500,
                      ),
                    ),
                  ),
                icon ?? const SizedBox.shrink(),
              ],
            )
          : Row(
              mainAxisSize: mainAxisSize ?? MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                title != null
                    ? Flexible(
                        fit: FlexFit.loose,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 8,
                            right: 8,
                            bottom: 10,
                            top: 4,
                          ),
                          // padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: PText(
                            title: title!.tr(context: context),
                            size: size ?? PSize.text18,
                            fontColor: textColor ?? AppColors.whiteColor,
                            fontWeight: fontWeight ?? FontWeight.w500,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
                (icon != null && title != null)
                    ? const SizedBox(width: 8)
                    : const SizedBox.shrink(),
                icon ?? const SizedBox.shrink(),
              ],
            ),
    );
  }
}

/// Generic button that reacts to [SafeCubit] state changes
class PButton<C extends SafeCubit<S>, S> extends StatelessWidget {
  final GestureTapCallback? onPressed;
  final String? title;
  final PSize? size;
  final FontWeight? fontWeight;
  final List<String>? dropDown;
  final double? borderRadius;
  final double? elevation;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadiusGeometry;
  final Widget? icon;
  final Color? textColor;
  final MainAxisSize? mainAxisSize;
  final bool hasCubit;
  final bool isFitWidth;
  final Color? fillColor;

  final Color? borderColor;
  final bool isButtonAlwaysExist;
  final bool isLeftIcon;
  final Widget? loadingWidget;
  final bool isFirstButton;

  const PButton({
    super.key,
    required this.onPressed,
    this.size,
    this.borderRadiusGeometry,
    this.isFitWidth = false,
    this.isLeftIcon = false,
    this.hasCubit = true,
    this.mainAxisSize,
    this.title,
    this.icon,
    this.dropDown,
    this.textColor,
    this.fillColor,

    this.borderRadius,
    this.padding,
    this.elevation,
    this.borderColor,
    this.isButtonAlwaysExist = true,
    this.loadingWidget,
    this.isFirstButton = true,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasCubit) {
      /// No Cubit → Just a static button
      return ButtonWidget(
        key: key,
        onPressed: onPressed,
        dropDown: dropDown,
        isLeftIcon: isLeftIcon,
        elevation: elevation,
        fillColor: fillColor,
        icon: icon,
        borderRadiusGeometry: borderRadiusGeometry,
        mainAxisSize: mainAxisSize,
        isFitWidth: isFitWidth,
        padding: padding,
        size: size,
        borderRadius: borderRadius,
        textColor: textColor,
        borderColor: borderColor,
        title: title,
      );
    }

    /// With Cubit → Dynamic button
    return BlocConsumer<C, S>(
      listener: (context, state) {
        AppLog.printValueAndTitle('Button state', state);
        if (state is LoadedState) {
          final dynamic data = state.data;
          final String? message = data is ApiResponse ? data.message : null;
          if (message != null && message.isNotEmpty) {
            PToast.showToast(
              context: context,
              message: message,
              duration: const Duration(seconds: 1),
              type: MessageType.success,
            );
          }
        }
      },

      /// Only rebuild when button visual state changes
      buildWhen: (previous, current) =>
          current is ButtonLoadingState ||
          current is ButtonDisabledState ||
          current is ErrorState ||
          current is ButtonEnabledState ||
          current is LoadedState,
      builder: (context, state) {
        /// Show a loader instead of the button (if required)
        if (state is ButtonLoadingState &&
            (isFirstButton == state.isFirstButtonLoading) &&
            !isButtonAlwaysExist) {
          return loadingWidget ??
              Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: (!isFirstButton)
                      ? isDark
                            ? AppColors.darkInactiveButtonColor
                            : AppColors.whiteColor
                      : isDark
                      ? AppColors.darkInactiveButtonColor
                      : AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(borderRadius ?? 4),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkInactiveButtonColor
                        : AppColors.primaryColor,
                  ),
                ),
                constraints: const BoxConstraints(minWidth: 60, minHeight: 48),
                child: CustomLoader(
                  loadingShape: LoadingShape.fadingCircle,
                  color: (!isFirstButton)
                      ? AppColors.primaryColor
                      : AppColors.whiteColor,
                  size: 40,
                ),
              );
        }

        /// Regular Button
        return ButtonWidget(
          key: key,
          borderRadiusGeometry: borderRadiusGeometry,
          onPressed:
              ((state is ButtonDisabledState && isFirstButton) ||
                  state is ButtonLoadingState)
              ? null
              : onPressed,
          dropDown: dropDown,
          elevation: elevation,
          mainAxisSize: mainAxisSize,
          borderColor: (state is ButtonDisabledState && isFirstButton)
              ? isDark
                    ? AppColors.darkInactiveButtonColor
                    : AppColors.inactiveButtonColor
              : (state is ButtonLoadingState &&
                    (isFirstButton != state.isFirstButtonLoading))
              ? isDark
                    ? AppColors.darkInactiveButtonColor
                    : AppColors.inactiveButtonColor
              : borderColor,
          fillColor: (state is ButtonDisabledState && isFirstButton)
              ? isDark
                    ? AppColors.darkInactiveButtonColor
                    : AppColors.inactiveButtonColor
              : (state is ButtonLoadingState &&
                    (isFirstButton != state.isFirstButtonLoading))
              ? isDark
                    ? AppColors.darkInactiveButtonColor
                    : AppColors.inactiveButtonColor
              : fillColor,
          icon: icon,
          isFitWidth: isFitWidth,
          padding: padding,
          size: size,
          borderRadius: borderRadius,
          textColor: textColor,
          title: title,
          fontWeight: fontWeight ?? FontWeight.w500,
        );
      },
    );
  }
}
