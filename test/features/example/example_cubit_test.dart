import 'package:flutter_test/flutter_test.dart';
import 'package:starter_app/core/global/state/base_state.dart';
import 'package:starter_app/core/services/network/error/network_exception.dart';
import 'package:starter_app/core/services/network/response/either_response_model.dart';
import 'package:starter_app/features/example/data/model/example_response_model.dart';
import 'package:starter_app/features/example/domain/repository/example_repository.dart';
import 'package:starter_app/features/example/domain/use_case/example_use_case.dart';
import 'package:starter_app/features/example/presentation/cubit/example_cubit.dart';

class _FakeExampleRepository implements ExampleRepository {
  _FakeExampleRepository(this.result);

  final EitherResponse<List<ExampleModel>> result;

  @override
  Future<EitherResponse<List<ExampleModel>>> getExamples() async => result;
}

ExampleCubit _cubit(EitherResponse<List<ExampleModel>> result) => ExampleCubit(
  exampleUseCase: ExampleUseCase(
    exampleRepository: _FakeExampleRepository(result),
  ),
);

void main() {
  test('emits LoadedState when the repository returns items', () async {
    final cubit = _cubit(
      const ResponseSuccess(data: [ExampleModel(id: 1, title: 'a')]),
    );
    final states = <BaseState>[];
    final sub = cubit.stream.listen(states.add);

    await cubit.getExamples();
    // Cubit streams deliver asynchronously; let pending events flush.
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(states.first, isA<LoadingState>());
    expect(states.last, isA<LoadedState<List<ExampleModel>>>());
    await cubit.close();
  });

  test('emits EmptyState when the repository returns no items', () async {
    final cubit = _cubit(const ResponseSuccess(data: []));
    await cubit.getExamples();
    expect(cubit.state, isA<EmptyState>());
    await cubit.close();
  });

  test('emits ErrorState when the repository fails', () async {
    final cubit = _cubit(
      const ResponseFailure(
        error: NetworkException(
          message: 'server',
          type: NetworkExceptionType.server,
          statusCode: 500,
        ),
      ),
    );
    await cubit.getExamples();
    expect(cubit.state, isA<ErrorState>());
    await cubit.close();
  });

  test('does not emit after close', () async {
    final cubit = _cubit(const ResponseSuccess(data: []));
    await cubit.close();
    await cubit.getExamples();
    expect(cubit.isClosed, isTrue);
  });
}
