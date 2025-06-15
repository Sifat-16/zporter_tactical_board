import 'package:intl/intl.dart';

class FileNameGenerator {
  static String generateZporterCaptureFilename() {
    // Get the current date and time
    final DateTime now = DateTime.now();

    // Define the prefix for the filename
    const String prefix = "Zporter Tactic Scene Capture ";

    // Format the main date and time part (YYYY-MM-DD-HHMM-SS)
    // HH for 24-hour format, mm for minutes, ss for seconds.
    final String dateTimeFormat = DateFormat('yyyy-MM-dd-HHmm-ss').format(now);

    // Get the milliseconds and format the MS part (first two digits of milliseconds)
    // now.millisecond gives a value from 0 to 999.
    // We divide by 10 and take the floor to get the first two significant digits.
    // For example:
    // - 5ms   -> (5/10).floor() = 0   -> "00"
    // - 75ms  -> (75/10).floor() = 7  -> "07"
    // - 123ms -> (123/10).floor() = 12 -> "12"
    // - 987ms -> (987/10).floor() = 98 -> "98"
    final String millisecondsPart =
        (now.millisecond / 10).floor().toString().padLeft(2, '0');

    // Concatenate all parts to form the final filename
    return "$prefix$dateTimeFormat$millisecondsPart";
  }
}
