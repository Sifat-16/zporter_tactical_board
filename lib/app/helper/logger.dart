import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/services/injection_container.dart';

void zlog({required dynamic data}) {
  if (kDebugMode) {
    Logger logger = sl.get<Logger>();
    logger.log(Level.info, data);
  } else {}
}
