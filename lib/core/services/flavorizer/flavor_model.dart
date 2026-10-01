import '../../global/enums/global_enum.dart';

class FlavorModel {
  String? title;
  String? description;
  String? baseUrl;
  String? iosBundleId;
  String? androidBundleId;
  FlavorsTypes? flavorType;

  FlavorModel({
    this.title,
    this.description,
    this.baseUrl,
    this.iosBundleId,
    this.androidBundleId,
    this.flavorType,
  });

  FlavorModel.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];
    baseUrl = json['base_url'];
    iosBundleId = json['iosBundleId'];
    androidBundleId = json['androidBundleId'];
    flavorType = FlavorsTypes.values
        .where((element) => element.name == json['flavorType'])
        .firstOrNull;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    data['description'] = description;
    data['base_url'] = baseUrl;
    data['flavorType'] = flavorType?.name;
    data['iosBundleId'] = iosBundleId;
    data['androidBundleId'] = androidBundleId;
    return data;
  }

  @override
  String toString() {
    return 'FlavorModel(title: $title, description: $description, baseUrl: $baseUrl, iosBundleId: $iosBundleId, androidBundleId: $androidBundleId, flavorType: $flavorType)';
  }
}
