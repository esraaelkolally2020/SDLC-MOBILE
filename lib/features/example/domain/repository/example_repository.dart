import '../../../../core/services/network/response/either_response_model.dart';
import '../../data/model/example_response_model.dart';

abstract class ExampleRepository {
  Future<EitherResponse<List<ExampleModel>>> getExamples();
}
