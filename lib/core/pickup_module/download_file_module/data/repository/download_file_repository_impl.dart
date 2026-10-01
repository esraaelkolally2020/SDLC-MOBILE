import 'package:starter_app/core/pickup_module/download_file_module/data/model/download_file_response_model.dart';
import 'package:starter_app/core/pickup_module/download_file_module/domain/download_file_repository/download_file_repository.dart';
import 'package:starter_app/core/services/network/interface/network_client_interface.dart';
import 'package:starter_app/core/services/network/response/api_response.dart';
import 'package:starter_app/core/services/network/response/either_response_model.dart';

import '../../../../data/repository/main_repository.dart';

class DownloadFileRepositoryImpl extends MainRepository
    implements DownloadFileRepository {
  DownloadFileRepositoryImpl({required super.remoteData});

  @override
  Future<EitherResponse<ApiResponse<DownloadFileResponseModel>>> download({
    required String endPoint,
    required int id,
    String? fileType,
  }) {
    final uri = Uri.parse(endPoint);

    final newUri = uri.replace(
      queryParameters: {
        ...uri.queryParameters,
        'fileId': id.toString(),
        if (fileType != null && fileType.isNotEmpty) 'fileType': fileType,
      },
    );

    return remoteData.request(
      method: HttpMethod.get,
      endpoint: newUri.toString(),
      parser: (data) => ApiResponse.fromMap(
        data,
        (d) => const DownloadFileResponseModel().fromMap(d),
      ),
    );
  }
}
