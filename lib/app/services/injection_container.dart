import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:zporter_tactical_board/app/config/feature_flags.dart';
import 'package:zporter_tactical_board/app/config/database/remote/appwrite_db.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_lineup_datasource.dart';
import 'package:zporter_tactical_board/data/admin/datasource/local/lineup_cache_datasource_impl.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/default_animation_datasource_impl.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/default_lineup_datasource_impl.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/notification_admin_datasource.dart';
import 'package:zporter_tactical_board/data/admin/datasource/remote/tutorial_datasource_impl.dart';
import 'package:zporter_tactical_board/data/admin/datasource/tutorial_datasource.dart';
import 'package:zporter_tactical_board/data/admin/service/file_storage_service.dart';
import 'package:zporter_tactical_board/data/admin/service/notification_admin_service.dart';
import 'package:zporter_tactical_board/data/animation/datasource/animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/datasource/local/animation_local_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/datasource/remote/animation_remote_datasource_impl.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository.dart';
import 'package:zporter_tactical_board/domain/admin/default_animation/default_animation_repository_impl.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository.dart';
import 'package:zporter_tactical_board/domain/admin/lineup/default_lineup_repository_impl.dart';
import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository.dart';
import 'package:zporter_tactical_board/domain/admin/notification/notification_admin_repository_impl.dart';
import 'package:zporter_tactical_board/domain/admin/tutorial/tutorial_repository.dart';
import 'package:zporter_tactical_board/domain/admin/tutorial/tutorial_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/repository/animation_cache_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/repository/animation_repository_impl.dart';
import 'package:zporter_tactical_board/domain/animation/usecase/delete_animation_collection_usecase.dart';
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

// Phase 2: Sync Services
import 'package:zporter_tactical_board/app/services/network/connectivity_service.dart'
    as connectivity_service;
import 'package:zporter_tactical_board/app/services/sync/sync_queue_manager.dart';
import 'package:zporter_tactical_board/app/services/sync/sync_orchestrator_service.dart';

// Phase 2 Week 2: Image Storage Services
import 'package:zporter_tactical_board/app/services/storage/image_storage_service.dart';
import 'package:zporter_tactical_board/app/services/storage/image_cache_manager.dart';

import 'connectivity_service.dart';
import 'firebase_storage_service.dart';
import 'user_preferences_service.dart';

final sl = GetIt.instance;

Future<void> initializeTacticBoardDependencies() async {
  // ============================================================
  // LOCAL-FIRST APPROACH: Initialize Firebase in background
  // App starts immediately with local data, Firebase connects when ready
  // ============================================================

  // Start Firebase initialization in background (non-blocking)
  _initializeFirebaseInBackground();

  // Continue with immediate app initialization
  sl.registerLazySingleton<Logger>(() => Logger());

  // Register UserPreferencesService
  sl.registerLazySingleton<UserPreferencesService>(
      () => UserPreferencesService());

  await ConnectivityService.initialize();

  // sl.registerLazySingletonAsync<MongoDB>(() async {
  //   final mongoDB = MongoDB();
  //   await mongoDB.connect();
  //   return mongoDB;
  // });
  //
  // await sl.isReady<MongoDB>();

  // ============================================================
  // PHASE 2: Sync Services
  // ============================================================

  // Register ConnectivityService (Phase 2)
  sl.registerLazySingleton<connectivity_service.ConnectivityService>(
    () => connectivity_service.ConnectivityService(),
  );

  // Register SyncQueueManager (Phase 2)
  sl.registerLazySingleton<SyncQueueManager>(
    () => SyncQueueManager(
      localDataSource: AnimationLocalDatasourceImpl(),
      remoteDataSource: AnimationRemoteDatasourceImpl(),
    ),
  );

  // Register SyncOrchestratorService (Phase 2)
  sl.registerLazySingleton<SyncOrchestratorService>(
    () => SyncOrchestratorService(
      queueManager: sl.get<SyncQueueManager>(),
      connectivityService: sl.get<connectivity_service.ConnectivityService>(),
    ),
  );

  // ============================================================
  // PHASE 2 Week 2: Image Storage Services
  // ============================================================

  // Register ImageStorageService (Phase 2 Week 2)
  sl.registerLazySingleton<ImageStorageService>(
    () => ImageStorageService(),
  );

  // Register ImageCacheManager (Phase 2 Week 2)
  sl.registerLazySingleton<ImageCacheManager>(
    () => ImageCacheManager(),
  );

  // ============================================================
  // Animation
  // ============================================================

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
      syncQueueManager: sl.get<SyncQueueManager>(), // Phase 2
      imageStorageService: sl.get<ImageStorageService>(), // Phase 2 Week 2
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

  sl.registerLazySingleton<DeleteAnimationCollectionUseCase>(
    () => DeleteAnimationCollectionUseCase(
      repository: sl.get<AnimationRepository>(instanceName: "local"),
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

  // default line up
  sl.registerLazySingleton<DefaultLineupDatasource>(
    () => DefaultLineupDatasourceImpl(),
  );
  sl.registerLazySingleton<LineupCacheDataSource>(
    () => LineupCacheDataSourceImpl(),
  );
  sl.registerLazySingleton<DefaultLineupRepository>(
    () => DefaultLineupRepositoryImpl(
      localDataSource: sl.get(),
      localCacheDataSource: sl.get(),
    ),
  );

  //default animation
  sl.registerLazySingleton<DefaultAnimationDatasource>(
    () => DefaultAnimationDatasourceImpl(),
  );
  sl.registerLazySingleton<DefaultAnimationRepository>(
    () => DefaultAnimationRepositoryImpl(datasource: sl.get()),
  );

  //tutorials
  sl.registerLazySingleton<AppwriteClientFactory>(
    () => AppwriteClientFactory(),
  );
  sl.registerLazySingleton<TutorialDatasource>(
    () => TutorialDatasourceHybridImpl(
        appwriteStorage: Storage(sl.get<AppwriteClientFactory>().create()),
        appwriteEndpoint: sl.get<AppwriteClientFactory>().appwriteEndpoint,
        appwriteProjectId: sl.get<AppwriteClientFactory>().appwriteProjectId),
  );

  sl.registerLazySingleton<TutorialRepository>(
    () => TutorialRepositoryImpl(datasource: sl.get()),
  );

  // Admin Notifications

  sl.registerLazySingleton<NotificationAdminService>(
    () => NotificationAdminService(),
  );

  sl.registerLazySingleton<NotificationAdminDataSource>(
    () => NotificationAdminDataSourceImpl(FirebaseFirestore.instance),
  );

  sl.registerLazySingleton<NotificationAdminRepository>(
    () => NotificationAdminRepositoryImpl(
      sl.get<NotificationAdminService>(),
      sl.get<NotificationAdminDataSource>(),
    ),
  );

  sl.registerLazySingleton<FileStorageService>(
    () => FileStorageService(FirebaseStorage.instance),
  );

  // ============================================================
  // PHASE 2: Start Sync Orchestrator
  // ============================================================
  // CRITICAL: Start the sync orchestrator to enable automatic background sync
  // This must happen AFTER all dependencies are registered
  if (FeatureFlags.enableSyncOrchestrator) {
    try {
      final orchestrator = sl.get<SyncOrchestratorService>();
      orchestrator.start();
      print('[Init] Sync orchestrator started successfully');
    } catch (e) {
      print('[Init] Failed to start sync orchestrator: $e');
      // Non-critical - app can continue without background sync
    }
  }
}

// ============================================================
// BACKGROUND FIREBASE INITIALIZATION (LOCAL-FIRST)
// ============================================================

/// Initialize Firebase in background without blocking app startup.
/// This is the correct local-first approach:
/// 1. App starts immediately with local Sembast data
/// 2. Firebase connects asynchronously when network is available
/// 3. No timeouts, no delays, no blocking - just start when ready
void _initializeFirebaseInBackground() {
  // Fire and forget - let Firebase initialize whenever it can
  Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((_) {
    print('[Init] Firebase initialized successfully');

    // Configure Firestore after successful initialization
    _configureFirebaseServices();

    // Initialize secondary Firebase app for image storage
    _initializeSecondaryFirebaseApp();
  }).catchError((e) {
    print('[Init] Firebase initialization failed: $e');
    print('[Init] App will continue in offline-only mode');
    // App continues working fine with local Sembast storage
  });
}

/// Configure Firestore settings after Firebase is initialized
void _configureFirebaseServices() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    print('[Init] Firebase services configured');
  } catch (e) {
    print('[Init] Firebase services configuration failed: $e');
  }
}

/// Initialize secondary Firebase app for image storage (background)
void _initializeSecondaryFirebaseApp() {
  FirebaseOptions secondaryOptions;

  if (kIsWeb) {
    secondaryOptions = DefaultFirebaseOptions.secondaryProjectOptionsWeb;
  } else {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        secondaryOptions =
            DefaultFirebaseOptions.secondaryProjectOptionsAndroid;
        break;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        secondaryOptions = DefaultFirebaseOptions.secondaryProjectOptionsIOS;
        break;
      default:
        print('[Init] Secondary Firebase not supported on this platform');
        return;
    }
  }

  FirebaseStorageService.initializeSecondaryApp(secondaryOptions).then((_) {
    print('[Init] Secondary Firebase app initialized');
  }).catchError((e) {
    print('[Init] Secondary Firebase app initialization failed: $e');
    // Image upload will be disabled, but app works fine otherwise
  });
}
