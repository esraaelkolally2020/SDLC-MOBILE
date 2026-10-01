import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../component/custom_toast/p_toast.dart';
import '../../../global/enums/global_enum.dart';

class ConnectivityDefaultActions {
  static void showOfflineSnackbar([BuildContext? context]) {
    PToast.showToast(
      message: 'noInternetConnection'.tr(),
      type: MessageType.error,
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
    );
  }

  static void showOnlineSnackbar([BuildContext? context]) {
    PToast.showToast(
      message: 'youAreBackOnline'.tr(),
      type: MessageType.success,
      duration: const Duration(seconds: 3),
      position: ToastPosition.top,
    );
  }

  static void dismiss() {
    PToast.dismiss();
  }
}
