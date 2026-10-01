import '../../../cubit/safe_cubit.dart';
import '../../../extensions/string_extensions.dart';
import '../../../global/state/base_state.dart';
import '../domain/use_case/download_file_use_case.dart';
import 'download_saver.dart';

class DownloadFileCubit extends SafeCubit<BaseState> {
  final DownloadFileUseCase downloadFileUseCase;

  DownloadFileCubit({required this.downloadFileUseCase})
    : super(const InitialState());

  Future<void> download({
    String? endPoint,
    int? id,
    String? fileType,
    String? fileName,
    String? fileBinary,
  }) async {
    emit(LoadingState());

    if (!endPoint.isEmptyOrNull) {
      final response = await downloadFileUseCase.download(
        endPoint: endPoint!,
        id: id!,
        fileType: fileType,
      );
      await response.fold(
        (error) {
          emit(ErrorState(error.message));
        },
        (r) async {
          final model = r?.data;

          final fileName = model?.data?.fileName ?? 'file.bin';
          final fileBinary = model?.data?.fileBinary ?? '';
          await saveAndPreview(fileBinary: fileBinary, fileName: fileName);
          emit(LoadedState(r));
        },
      );
    } else {
      await saveAndPreview(fileBinary: fileBinary!, fileName: fileName!);
      emit(const LoadedState(''));
    }
  }

  Future<void> saveAndPreview({
    required String fileName,
    required String fileBinary,
  }) async {
    try {
      await saveAndPreviewFile(fileName: fileName, fileBinary: fileBinary);
    } catch (e) {
      emit(ErrorState(e.toString()));
    }
  }
}
