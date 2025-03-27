import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/config/database/remote/mongodb.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerLazySingleton<Logger>(() => Logger());

  sl.registerLazySingletonAsync<MongoDB>(() async {
    final mongoDB = MongoDB();
    await mongoDB.connect();
    return mongoDB;
  });

  await sl.isReady<MongoDB>();

  // Board bloc
}
