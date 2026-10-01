import '../../../../services/network/response/api_response.dart';
import '../../../../services/network/response/either_response_model.dart';
import '../../data/model/download_file_response_model.dart';

abstract class DownloadFileRepository {
  Future<EitherResponse<ApiResponse<DownloadFileResponseModel>>> download({
    required String endPoint,
    required int id,
    String? fileType,
  });
}
