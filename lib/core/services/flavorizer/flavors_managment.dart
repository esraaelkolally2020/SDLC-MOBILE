import '../../global/enums/global_enum.dart';
import '../log/app_log.dart';
import 'flavor_model.dart';
import 'flavors.dart';

class FlavorsManagement {
  FlavorsManagement._privateConstructor();
  static final FlavorsManagement instance =
      FlavorsManagement._privateConstructor();

  late final Flavor flavor;

  bool get isDevFlavor => getCurrentFlavor.flavorType == FlavorsTypes.dev;
  bool get isStageFlavor => getCurrentFlavor.flavorType == FlavorsTypes.stage;
  bool get isProdFlavor => getCurrentFlavor.flavorType == FlavorsTypes.prod;

  final List<Flavor> availableFlavors = [
    DevelopmentFlavor(),
    StageFlavor(),
    ProductionFlavor(),
  ];

  FlavorModel get getCurrentFlavor {
    return flavor.getCurrentFlavor;
  }

  /// Flutter sets `FLUTTER_APP_FLAVOR` automatically from `--flavor`.
  /// Without a flavor (e.g. web builds) the production flavor is used.
  void init() {
    AppLog.printValue('Init Flavors Management');
    const String flavorName = String.fromEnvironment('FLUTTER_APP_FLAVOR');

    AppLog.printValueAndTitle('Flavor Name', flavorName);
    flavor = availableFlavors.firstWhere(
      (e) => e.getCurrentFlavor.flavorType!.name == flavorName,
      orElse: () => ProductionFlavor(),
    );
    AppLog.printValue(flavor.getCurrentFlavor.toString());
  }
}
