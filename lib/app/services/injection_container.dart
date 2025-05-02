import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/datasource/local/animation_local_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/datasource/remote/animation_remote_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/animation/repository/animation_cache_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/repository/animation_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/delete_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_all_default_animation_items_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_default_scene_from_id_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_stream_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/get_history_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_animation_collection_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_default_animation_usecase.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/save_history_usecase.dart';
import 'package:zporter_tactical_board/firebase_options.dart';

import 'connectivity_service.dart';

final sl = GetIt.instance;

Future<void> initializeTacticBoardDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Or a specific limit
  );
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  sl.registerLazySingleton<Logger>(() => Logger());

  ConnectivityService.initialize();

  // sl.registerLazySingletonAsync<MongoDB>(() async {
  //   final mongoDB = MongoDB();
  //   await mongoDB.connect();
  //   return mongoDB;
  // });
  //
  // await sl.isReady<MongoDB>();

  // Animation

  sl.registerLazySingleton<AnimationDatasource>(
    () => AnimationRemoteDatasourceImpl(),
    instanceName: "remote",
  );
  sl.registerLazySingleton<AnimationDatasource>(
    () => AnimationLocalDatasourceImpl(),
    instanceName: "local",
  );
  sl.registerLazySingleton<AnimationRepository>(
    () => AnimationRepositoryImpl(
      animationDatasource: sl.get<AnimationDatasource>(instanceName: "remote"),
    ),
    instanceName: "remote",
  );

  sl.registerLazySingleton<AnimationRepository>(
    () => AnimationCacheRepositoryImpl(
      localDatasource: sl.get<AnimationDatasource>(instanceName: "local"),
      remoteDatasource: sl.get<AnimationDatasource>(instanceName: "remote"),
    ),
    instanceName: "local",
  );
  sl.registerLazySingleton<SaveAnimationCollectionUseCase>(
    () => SaveAnimationCollectionUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );
  sl.registerLazySingleton<GetAllAnimationCollectionUseCase>(
    () => GetAllAnimationCollectionUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<GetAllDefaultAnimationItemsUseCase>(
    () => GetAllDefaultAnimationItemsUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<SaveDefaultAnimationUseCase>(
    () => SaveDefaultAnimationUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<GetDefaultSceneFromIdUseCase>(
    () => GetDefaultSceneFromIdUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<GetHistoryUseCase>(
    () => GetHistoryUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<DeleteHistoryUseCase>(
    () => DeleteHistoryUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<SaveHistoryUseCase>(
    () => SaveHistoryUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  sl.registerLazySingleton<GetHistoryStreamUseCase>(
    () => GetHistoryStreamUseCase(
      animationRepository: sl.get<AnimationRepository>(instanceName: "local"),
    ),
  );

  // Board bloc
}
