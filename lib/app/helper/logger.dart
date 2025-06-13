import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';

void zlog({required dynamic data, Level? level, bool show = false}) {
  if (kDebugMode) {
    if (show) {
      Logger logger = sl.get<Logger>();
      logger.log(Level.info, data);
    } else {}
  } else {}
}
