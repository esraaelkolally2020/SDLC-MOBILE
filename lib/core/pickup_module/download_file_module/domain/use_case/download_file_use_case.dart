import 'package:starter_app/core/pickup_module/download_file_module/domain/download_file_repository/download_file_repository.dart';
import 'package:starter_app/core/services/network/response/api_response.dart';
import 'package:starter_app/core/services/network/response/either_response_model.dart';

import '../../data/model/download_file_response_model.dart';

class DownloadFileUseCase {
  final DownloadFileRepository downloadFileRepository;
  DownloadFileUseCase({required this.downloadFileRepository});

  Future<EitherResponse<ApiResponse<DownloadFileResponseModel>>> download({
    required String endPoint,
    required int id,
    String? fileType,
  }) async {
    return await downloadFileRepository.download(
      endPoint: endPoint,
      id: id,
      fileType: fileType,
    );
  }
}
