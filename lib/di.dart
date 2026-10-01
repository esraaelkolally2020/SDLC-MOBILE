import 'package:get_it/get_it.dart';

import 'core/data/constants/global_obj.dart';
import 'core/pickup_module/download_file_module/data/repository/download_file_repository_impl.dart';
import 'core/pickup_module/download_file_module/domain/download_file_repository/download_file_repository.dart';
import 'core/pickup_module/download_file_module/domain/use_case/download_file_use_case.dart';
import 'core/services/connectivity/connectivity_listener.dart';
import 'core/services/flavorizer/flavors_managment.dart';
import 'core/services/network/client/dio_network_client.dart';
import 'core/services/network/error/bottom_sheet_parsing_error_reporter.dart';
import 'core/services/network/error/network_exception_handler.dart';
import 'core/services/network/interface/network_client_interface.dart';
import 'core/services/sentry/app_sentry.dart';
import 'features/example/data/repository/example_repository_impl.dart';
import 'features/example/domain/repository/example_repository.dart';
import 'features/example/domain/use_case/example_use_case.dart';

final GetIt getIt = GetIt.instance;

class AppDependencies {
  Future<void> inject() async {
    /////////////////////////////// Use cases
    getIt.registerLazySingleton<DownloadFileUseCase>(
      () => DownloadFileUseCase(downloadFileRepository: getIt()),
    );

    getIt.registerLazySingleton<ExampleUseCase>(
      () => ExampleUseCase(exampleRepository: getIt()),
    );

    /////////////////////////////// Repositories
    getIt.registerLazySingleton<DownloadFileRepository>(
      () => DownloadFileRepositoryImpl(remoteData: getIt()),
    );

    getIt.registerLazySingleton<ExampleRepository>(
      () => ExampleRepositoryImpl(remoteData: getIt()),
    );

    /////////////////////////////// Network
    // Initialize dio client
    getIt.registerLazySingleton<NetworkClientInterface>(
      () => DioNetworkClient(
        errorHandler: NetworkExceptionHandler(
          baseUrl: DioNetworkClient.baseUrl,
          // Show parsing error bottom sheet in development flavor only
          parsingErrorReporter: FlavorsManagement.instance.isDevFlavor
              ? const BottomSheetParsingErrorReporter()
              : null,
          // Report errors to Sentry only when it was initialized (prod + DSN)
          logErrorHandlers: AppSentryLogger.isInitialized
              ? [AppSentryLogger.instance]
              : null,
        ),
      ),
    );

    /////////////////////////////// Services
    // Initialize connectivity listener
    getIt.registerLazySingleton<IConnectivityListener>(
      () => ConnectivityListenerService(
        contextGetter: () => navigatorKey.currentContext,
      ),
    );
    getIt<IConnectivityListener>().init();
  }
}
