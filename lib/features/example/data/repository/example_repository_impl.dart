import '../../../../core/data/constants/api_endpoints_constants.dart';
import '../../../../core/data/repository/main_repository.dart';
import '../../../../core/services/network/interface/network_client_interface.dart';
import '../../../../core/services/network/response/either_response_model.dart';
import '../../domain/repository/example_repository.dart';
import '../model/example_response_model.dart';

class ExampleRepositoryImpl extends MainRepository
    implements ExampleRepository {
  ExampleRepositoryImpl({required super.remoteData});

  // The demo API returns a bare JSON list. Real backend endpoints return the
  // standard envelope, so parse them with
  // `ApiResponse.fromMap(data, (d) => ...)` and return
  // `EitherResponse<ApiResponse<T>>` instead.
  @override
  Future<EitherResponse<List<ExampleModel>>> getExamples() {
    return remoteData.request(
      method: HttpMethod.get,
      endpoint: ApiEndpointsConstants.examples,
      parser: (data) => (data as List)
          .map((e) => ExampleModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
