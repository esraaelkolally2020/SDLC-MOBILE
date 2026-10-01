import 'package:flutter/material.dart';

import 'example_mobile_body.dart';

class ExampleDesktopBody extends StatelessWidget {
  const ExampleDesktopBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExampleMobileBody(crossAxisCount: 3);
  }
}
