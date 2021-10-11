import 'package:date_format/date_format.dart';

class TimeUtils {
  static getCurrentTimeFormat() {
    return formatDate(
        DateTime.now(), [yyyy, "_", mm, "_", dd, "_", HH, '_', nn, '_', ss]);
  }

  static getCurrentTime() {
    return DateTime.now().microsecond;
  }
}
