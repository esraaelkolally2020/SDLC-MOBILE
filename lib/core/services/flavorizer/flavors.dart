import '../../global/enums/global_enum.dart';
import 'flavor_model.dart';

abstract class Flavor {
  FlavorModel get getCurrentFlavor;
}

class DevelopmentFlavor extends Flavor {
  static const String _baseUrl = String.fromEnvironment('BASE_URL_DEV');

  @override
  FlavorModel get getCurrentFlavor => FlavorModel()
    ..title = 'Starter Dev'
    ..baseUrl = _baseUrl
    ..description = 'Development flavor'
    ..androidBundleId = 'com.example.starter_app.dev'
    ..iosBundleId = 'com.example.starterApp.dev'
    ..flavorType = FlavorsTypes.dev;
}

class StageFlavor extends Flavor {
  static const String _baseUrl = String.fromEnvironment('BASE_URL_STAGE');

  @override
  FlavorModel get getCurrentFlavor => FlavorModel()
    ..title = 'Starter Stage'
    ..baseUrl = _baseUrl
    ..description = 'Stage flavor'
    ..androidBundleId = 'com.example.starter_app.stage'
    ..iosBundleId = 'com.example.starterApp.stage'
    ..flavorType = FlavorsTypes.stage;
}

class ProductionFlavor extends Flavor {
  static const String _baseUrl = String.fromEnvironment('BASE_URL_PROD');

  @override
  FlavorModel get getCurrentFlavor => FlavorModel()
    ..title = 'Starter'
    ..baseUrl = _baseUrl
    ..description = 'Production flavor'
    ..androidBundleId = 'com.example.starter_app'
    ..iosBundleId = 'com.example.starterApp'
    ..flavorType = FlavorsTypes.prod;
}
