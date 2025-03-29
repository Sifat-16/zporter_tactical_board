import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/animation/repository/animation_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/firebase_options.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  sl.registerLazySingleton<Logger>(() => Logger());

  // sl.registerLazySingletonAsync<MongoDB>(() async {
  //   final mongoDB = MongoDB();
  //   await mongoDB.connect();
  //   return mongoDB;
  // });
  //
  // await sl.isReady<MongoDB>();

  // Animation

  sl.registerLazySingleton<AnimationDatasource>(
    () => AnimationDatasourceImpl(),
  );
  sl.registerLazySingleton<AnimationRepository>(
    () => AnimationRepositoryImpl(
      animationDatasource: sl.get<AnimationDatasource>(),
    ),
  );
  sl.registerLazySingleton<SaveAnimationCollectionUseCase>(
    () => SaveAnimationCollectionUseCase(
      animationRepository: sl.get<AnimationRepository>(),
    ),
  );
  sl.registerLazySingleton<GetAllAnimationCollectionUseCase>(
    () => GetAllAnimationCollectionUseCase(
      animationRepository: sl.get<AnimationRepository>(),
    ),
  );

  // Board bloc
}
