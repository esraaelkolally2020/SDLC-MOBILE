import 'package:flutter/material.dart';

import '../../data/constants/dimensions.dart';
import '../../services/platform/app_platform.dart';

/// Responsive scaffold that picks a body by available width:
/// mobile < [DimensionsConstants.mobileScreenWidth] ≤ tablet
/// < [DimensionsConstants.tabletScreenWidth] ≤ desktop
/// < [DimensionsConstants.desktopScreenWidth] ≤ web.
/// Missing bodies fall back to the next smaller layout.

class CustomLayoutBuilder extends StatelessWidget {
  final Widget mobileBody;
  final Widget? tabletBody;
  final Widget? webBody;
  final Widget? desktopBody;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  const CustomLayoutBuilder({
    super.key,
    required this.mobileBody,
    this.tabletBody,
    this.webBody,
    this.desktopBody,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.resizeToAvoidBottomInset,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: AppPlatform.isAndroid,
      child: Scaffold(
        appBar: appBar,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < DimensionsConstants.mobileScreenWidth) {
              return mobileBody;
            } else if (constraints.maxWidth <
                DimensionsConstants.tabletScreenWidth) {
              return tabletBody ?? mobileBody;
            } else if (constraints.maxWidth <
                DimensionsConstants.desktopScreenWidth) {
              return desktopBody ?? tabletBody ?? mobileBody;
            } else {
              return webBody ?? desktopBody ?? tabletBody ?? mobileBody;
            }
          },
        ),
      ),
    );
  }
}
