import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';

import 'app_services.dart';
import 'core/services/flavorizer/flavors_managment.dart';
import 'core/services/localization/app_localization.dart';
import 'core/services/sentry/app_sentry.dart';
import 'core/services/theme/theme_cubit.dart';
import 'di.dart';
import 'myapp.dart';

/// Sentry DSN, provided via `--dart-define-from-file=api_end_points.env`.
const String _sentryDsn = String.fromEnvironment('SENTRY_DSN');

/// App version reported to Sentry (optional dart-define `APP_VERSION`).
const String _appVersion = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
);

Future<void> main() async {
  // Init Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Set UI chrome preferences before the first frame is built.
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Init App Services
  await AppServices.init();

  // Inject your dependencies
  await AppDependencies().inject();

  // Sentry is only enabled for the prod flavor with a configured DSN.
  if (FlavorsManagement.instance.isProdFlavor && _sentryDsn.isNotEmpty) {
    await AppSentryLogger.init(
      projectName: 'starter_app',
      dsn: _sentryDsn,
      environment: FlavorsManagement.instance.getCurrentFlavor.flavorType!.name,
      release: _appVersion,
      appRunner: () async => _runApp(),
    );
  } else {
    _runApp();
  }
}

void _runApp() {
  runApp(
    BlocProvider(
      create: (_) => ThemeCubit(),
      child: EasyLocalization(
        supportedLocales: AppLocalization.getSupportedLocales,
        fallbackLocale: AppLocalization.fallbackLocale,
        path: AppLocalization.getPath,
        startLocale: AppLocalization.startLocale,
        saveLocale: true,
        child: Sizer(
          builder: (context, orientation, deviceType) => const MyApp(),
        ),
      ),
    ),
  );
}
