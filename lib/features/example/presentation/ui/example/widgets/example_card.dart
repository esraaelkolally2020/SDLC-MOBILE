import 'package:flutter/material.dart';

import '../../../../data/model/example_response_model.dart';

class ExampleCard extends StatelessWidget {
  const ExampleCard({super.key, required this.item});

  final ExampleModel item;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              item.body ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
