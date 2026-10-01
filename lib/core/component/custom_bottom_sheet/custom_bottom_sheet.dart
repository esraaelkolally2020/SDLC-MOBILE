import '../../services/platform/app_platform.dart';

import 'package:starter_app/core/data/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:starter_app/core/cubit/safe_cubit.dart';

import '../../data/constants/global_obj.dart';
import '../button/p_button.dart';

Future<dynamic> showCustomBottomSheet<C extends SafeCubit<S>, S>({
  BuildContext? context,
  required Widget body,
  C? cubit, // 👈 allow passing cubit
  bool isFullSheetWidget = false,
  bool withYesNoActions = false,
  String? okButtonTitle,
  String? yesButtonTitle,
  String? noButtonTitle,
  VoidCallback? okButtonAction,
  VoidCallback? yesButtonAction,
  VoidCallback? noButtonAction,

  bool hasCubit = false,
  bool isDismissible = true,
}) async {
  final ctx = context ?? Get.navigatorState!.context;

  return showModalBottomSheet(
    context: ctx,
    isDismissible: isDismissible,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
    builder: (innerContext) {
      Widget content = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.maybeViewInsetsOf(innerContext)?.bottom ?? 0,
        ),
        child: Material(
          color: Colors.white,
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: AppPlatform.isAndroid ? 52 : 24,
            ),
            width: double.infinity,
            child: (isFullSheetWidget
                ? body
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        body,

                        const SizedBox(height: 20),
                        withYesNoActions
                            ? Row(
                                children: [
                                  Expanded(
                                    child: PButton<C, S>(
                                      hasCubit: hasCubit,
                                      isFirstButton: true,
                                      isButtonAlwaysExist: false,
                                      onPressed:
                                          yesButtonAction ??
                                          () =>
                                              Navigator.of(innerContext)
                                                  .pop(true),
                                      title: yesButtonTitle ?? 'yes',
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: PButton<C, S>(
                                      hasCubit: hasCubit,
                                      isButtonAlwaysExist: false,
                                      isFirstButton: false,
                                      borderColor: AppColors.primaryColor,
                                      fillColor: AppColors.whiteColor,
                                      textColor: AppColors.black,
                                      onPressed:
                                          noButtonAction ??
                                          () =>
                                              Navigator.of(innerContext)
                                                  .pop(false),
                                      title: noButtonTitle ?? 'no',
                                    ),
                                  ),
                                ],
                              )
                            : PButton<C, S>(
                                hasCubit: hasCubit,
                                isButtonAlwaysExist: false,
                                isFirstButton: true,
                                isFitWidth: true,
                                onPressed:
                                    okButtonAction ??
                                    () => Navigator.of(innerContext).pop(true),
                                title: okButtonTitle ?? 'okay',
                              ),
                      ],
                    ),
                  )),
          ),
        ),
      );

      // 👇 wrap with BlocProvider if cubit is provided
      if (cubit != null) {
        return BlocProvider.value(value: cubit, child: content);
      }
      return content;
    },
  );
}
