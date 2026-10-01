import 'package:flutter/material.dart';

import 'example_mobile_body.dart';

class ExampleWebBody extends StatelessWidget {
  const ExampleWebBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExampleMobileBody(crossAxisCount: 2);
  }
}
