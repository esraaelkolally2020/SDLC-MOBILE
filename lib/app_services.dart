import 'package:easy_localization/easy_localization.dart';

import 'core/services/flavorizer/flavors_managment.dart';
import 'core/services/local_storage/shared_preference/shared_preference_service.dart';
import 'core/services/log/app_log.dart';
import 'core/services/session_manager/session_manager.dart';

class AppServices {
  static Future<void> init() async {
    try {
      await Future.wait([
        // Init localization
        EasyLocalization.ensureInitialized(),

        // Init shared preference
        SharedPreferenceService().init(),
      ]);

      // Init session manager (Must be called after Init shared preference)
      await SessionManager().init();
    } catch (e) {
      AppLog.printValue('AppServices.init() --> $e');
    }

    // Init flavors (reads FLUTTER_APP_FLAVOR and base URLs from dart-defines)
    FlavorsManagement.instance.init();
  }
}
