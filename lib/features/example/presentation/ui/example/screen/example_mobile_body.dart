import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/global/state/base_state.dart';
import '../../../../data/model/example_response_model.dart';
import '../../../cubit/example_cubit.dart';
import '../widgets/example_card.dart';

class ExampleMobileBody extends StatelessWidget {
  const ExampleMobileBody({super.key, this.crossAxisCount = 1});

  /// Web and desktop bodies reuse this widget with more columns.
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExampleCubit, BaseState>(
      builder: (context, state) {
        return switch (state) {
          LoadingState() ||
          InitialState() => const Center(child: CircularProgressIndicator()),
          ErrorState(:final data) => _Message(
            text: data?.toString() ?? 'something_went_wrong'.tr(),
            onRetry: context.read<ExampleCubit>().getExamples,
          ),
          LoadedState<List<ExampleModel>>(:final data) => RefreshIndicator(
            onRefresh: context.read<ExampleCubit>().getExamples,
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisExtent: 120,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: data?.length ?? 0,
              itemBuilder: (_, i) => ExampleCard(item: data![i]),
            ),
          ),
          _ => _Message(
            text: 'no_data_available'.tr(),
            onRetry: context.read<ExampleCubit>().getExamples,
          ),
        };
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});

  final String text;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: Text('retry'.tr())),
        ],
      ),
    );
  }
}
