import '../../../../core/services/network/response/either_response_model.dart';
import '../../data/model/example_response_model.dart';
import '../repository/example_repository.dart';

class ExampleUseCase {
  final ExampleRepository exampleRepository;

  ExampleUseCase({required this.exampleRepository});

  Future<EitherResponse<List<ExampleModel>>> getExamples() async {
    return await exampleRepository.getExamples();
  }
}
