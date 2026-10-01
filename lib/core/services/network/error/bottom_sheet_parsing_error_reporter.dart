import 'parsing_error_bottom_sheet.dart';
import 'parsing_error_reporter_interface.dart';

class BottomSheetParsingErrorReporter implements ParsingErrorReporterInterface {
  const BottomSheetParsingErrorReporter();

  @override
  void report(ParsingErrorReport report) {
    showErrorParsingBottomSheet(
      error: report.errorMessage,
      data: report.safeDisplayData,
      statusCode: report.statusCode,
    );
  }
}
