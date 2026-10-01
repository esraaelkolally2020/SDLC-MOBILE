import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../../../core/component/layout_builder/custom_layout_builder.dart';
import 'example_desktop_body.dart';
import 'example_mobile_body.dart';
import 'example_web_body.dart';

class ExampleMainScreen extends StatelessWidget {
  const ExampleMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomLayoutBuilder(
      appBar: AppBar(title: Text('example_title'.tr())),
      mobileBody: const ExampleMobileBody(),
      webBody: const ExampleWebBody(),
      desktopBody: const ExampleDesktopBody(),
    );
  }
}
