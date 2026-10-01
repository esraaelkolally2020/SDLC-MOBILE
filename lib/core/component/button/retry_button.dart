import 'package:flutter/material.dart';
import 'package:starter_app/core/data/constants/app_colors.dart';

class RetryButton extends StatelessWidget {
  final VoidCallback? onRetry;

  const RetryButton({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh, size: 30, color: AppColors.primaryColor),
    );
  }
}
