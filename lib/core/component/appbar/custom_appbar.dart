import 'package:starter_app/core/component/image/p_image.dart';
import 'package:starter_app/core/data/assets_helper/app_svg_icon.dart';
import 'package:starter_app/core/global/enums/global_enum.dart';
import 'package:starter_app/core/services/localization/app_localization.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/constants/app_colors.dart';
import '../text/p_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showBackButton;
  final VoidCallback? bottomSheetWidgetFormButtonAction;
  final VoidCallback? onBackPressed;
  final bool isCenterTitle;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showBackButton = true,
    this.isCenterTitle = false,
    this.onBackPressed,
    this.actions,
    this.bottomSheetWidgetFormButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> finalActions = [];

    if (actions != null && actions!.isNotEmpty) {
      finalActions.addAll(actions!);
    }

    return AppBar(
      leading: showBackButton
          ? CustomBackButton(onBackPressed: onBackPressed)
          : null,
      actions: finalActions,
      title:
          titleWidget ??
          PText(
            title: title?.tr(context: context) ?? '',
            fontColor: AppColors.whiteColor,
            fontWeight: FontWeight.w500,
            size: PSize.text18,
          ),
      centerTitle: isCenterTitle,
      titleSpacing: isCenterTitle ? null : 0,
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Colors.black,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onBackPressed;
  final Color? iconColor;
  const CustomBackButton({super.key, this.onBackPressed, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: PImage(
        source: AppLocalization.isArabic
            ? AppSvgIcons.backRight
            : AppSvgIcons.backLeft,
        height: 30,
        width: 30,
        color: iconColor,
        fit: BoxFit.fill,
      ),
      onPressed: () {
        if (onBackPressed != null) {
          onBackPressed!();
        } else {
          context.pop();
        }
      },
    );
  }
}
