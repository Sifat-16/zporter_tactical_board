import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zporter_tactical_board/app/helper/logger.dart';
import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

const String DEFAULT_ANIMATIONS_COLLECTION = "defaultAnimations";
const String DEFAULT_ANIMATION_COLLECTIONS = "defaultAnimationCollections";
const String SYSTEM_USER_ID_FOR_DEFAULTS = "system_default_user_for_animations";

class DefaultAnimationDatasourceImpl implements DefaultAnimationDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late final CollectionReference<Map<String, dynamic>> _animationsRef;
  late final CollectionReference<Map<String, dynamic>> _collectionsRef;

  DefaultAnimationDatasourceImpl() {
    _animationsRef = _firestore.collection(DEFAULT_ANIMATIONS_COLLECTION);
    _collectionsRef = _firestore.collection(DEFAULT_ANIMATION_COLLECTIONS);
  }

  // --- Animation Methods (Implementations of original methods) ---

  @override
  Future<List<AnimationModel>> getAllDefaultAnimations() async {
    final snapshot = await _animationsRef.get();
    return snapshot.docs
        .map((doc) => AnimationModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<AnimationModel> saveDefaultAnimation(
      AnimationModel animationModel) async {
    String docId =
        animationModel.id.isEmpty ? _animationsRef.doc().id : animationModel.id;
    final modelToSave =
        animationModel.copyWith(id: docId, userId: SYSTEM_USER_ID_FOR_DEFAULTS);
    await _animationsRef.doc(docId).set(modelToSave.toJson());
    return modelToSave;
  }

  @override
  Future<void> deleteDefaultAnimation(String animationId) async {
    await _animationsRef.doc(animationId).delete();
  }

  // --- Collection Methods (Implementations of new methods) ---

  @override
  Future<List<AnimationCollectionModel>>
      getAllDefaultAnimationCollections() async {
    final snapshot = await _collectionsRef.orderBy('orderIndex').get();
    return snapshot.docs
        .map((doc) => AnimationCollectionModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<AnimationCollectionModel> saveDefaultAnimationCollection(
      AnimationCollectionModel collection) async {
    String docId =
        collection.id.isEmpty ? _collectionsRef.doc().id : collection.id;
    final collectionToSave =
        collection.copyWith(id: docId, userId: SYSTEM_USER_ID_FOR_DEFAULTS);
    await _collectionsRef.doc(docId).set(collectionToSave.toJson());
    return collectionToSave;
  }

  @override
  Future<void> deleteDefaultAnimationCollection(String collectionId) async {
    final batch = _firestore.batch();
    final animationsSnapshot = await _animationsRef
        .where('collectionId', isEqualTo: collectionId)
        .get();
    for (final doc in animationsSnapshot.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_collectionsRef.doc(collectionId));
    await batch.commit();
  }

  @override
  Future<void> saveAllDefaultAnimationCollections(
      List<AnimationCollectionModel> collections) async {
    final batch = _firestore.batch();
    for (final collection in collections) {
      batch.set(_collectionsRef.doc(collection.id), collection.toJson(),
          SetOptions(merge: true));
    }
    await batch.commit();
  }

  // --- Migration Method ---

  @override
  Future<List<AnimationModel>> getOrphanedDefaultAnimations() async {
    final snapshot =
        await _animationsRef.where('collectionId', isNull: true).get();
    return snapshot.docs
        .map((doc) => AnimationModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations) async {
    final batch = _firestore.batch();
    for (final animation in animations) {
      final docRef = _animationsRef.doc(animation.id);
      batch.set(docRef, animation.toJson(), SetOptions(merge: true));
    }
    await batch.commit();
  }
}
