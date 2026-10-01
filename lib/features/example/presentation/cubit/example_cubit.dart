import '../../../../core/cubit/safe_cubit.dart';
import '../../../../core/global/state/base_state.dart';
import '../../domain/use_case/example_use_case.dart';

class ExampleCubit extends SafeCubit<BaseState> {
  final ExampleUseCase exampleUseCase;

  ExampleCubit({required this.exampleUseCase}) : super(const InitialState());

  Future<void> getExamples() async {
    emit(LoadingState());

    final response = await exampleUseCase.getExamples();

    response.fold((failure) => emit(ErrorState(failure.message)), (success) {
      final items = success ?? [];
      emit(items.isEmpty ? const EmptyState(null) : LoadedState(items));
    });
  }
}
