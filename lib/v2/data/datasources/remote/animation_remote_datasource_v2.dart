import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:zporter_tactical_board/v2/data/datasources/animation_datasource_v2.dart';
import 'package:zporter_tactical_board/v2/models/animation_collection.dart';

/// Firestore implementation of [AnimationDatasourceV2].
///
/// Uses the same collection name (`animation_collections`) as V1.
/// V2 models produce V1-compatible JSON, so V1 and V2 can share the same
/// Firestore data without migration.
class AnimationRemoteDatasourceV2 implements AnimationDatasourceV2 {
  final CollectionReference<Map<String, dynamic>> _collectionRef;

  AnimationRemoteDatasourceV2({FirebaseFirestore? firestore})
      : _collectionRef = (firestore ?? FirebaseFirestore.instance)
            .collection('animation_collections');

  @override
  Future<List<AnimationCollectionModelV2>> getAllCollections(
    String userId,
  ) async {
    try {
      final snapshot = await _collectionRef
          .where('userId', isEqualTo: userId)
          .get();

      final collections = <AnimationCollectionModelV2>[];
      for (final doc in snapshot.docs) {
        try {
          collections.add(AnimationCollectionModelV2.fromJson(doc.data()));
        } catch (e) {
          developer.log(
            'Skipping malformed Firestore doc: ${doc.id}',
            name: 'AnimationRemoteDatasourceV2',
            error: e,
          );
        }
      }
      return collections;
    } on FirebaseException catch (e) {
      developer.log(
        'Firebase error fetching collections for userId=$userId: '
        '${e.code} - ${e.message}',
        name: 'AnimationRemoteDatasourceV2',
      );
      throw Exception(
        'Error fetching animation collections: ${e.message}',
      );
    } catch (e) {
      developer.log(
        'Error fetching collections for userId=$userId',
        name: 'AnimationRemoteDatasourceV2',
        error: e,
      );
      throw Exception('Error fetching animation collections: $e');
    }
  }

  @override
  Future<AnimationCollectionModelV2?> getCollection(
    String collectionId,
  ) async {
    try {
      final doc = await _collectionRef.doc(collectionId).get();
      if (!doc.exists || doc.data() == null) return null;
      return AnimationCollectionModelV2.fromJson(doc.data()!);
    } on FirebaseException catch (e) {
      developer.log(
        'Firebase error fetching collection id=$collectionId: '
        '${e.code} - ${e.message}',
        name: 'AnimationRemoteDatasourceV2',
      );
      throw Exception(
        'Error fetching animation collection: ${e.message}',
      );
    } catch (e) {
      developer.log(
        'Error fetching collection id=$collectionId',
        name: 'AnimationRemoteDatasourceV2',
        error: e,
      );
      throw Exception('Error fetching animation collection: $e');
    }
  }

  @override
  Future<AnimationCollectionModelV2> saveCollection(
    AnimationCollectionModelV2 collection,
  ) async {
    try {
      var id = collection.id;
      if (id.isEmpty) {
        id = _collectionRef.doc().id;
        collection = collection.copyWith(id: id);
      }
      await _collectionRef.doc(id).set(collection.toJson());
      return collection;
    } on FirebaseException catch (e) {
      developer.log(
        'Firebase error saving collection id=${collection.id}: '
        '${e.code} - ${e.message}',
        name: 'AnimationRemoteDatasourceV2',
      );
      throw Exception(
        'Error saving animation collection: ${e.message}',
      );
    } catch (e) {
      developer.log(
        'Error saving collection id=${collection.id}',
        name: 'AnimationRemoteDatasourceV2',
        error: e,
      );
      throw Exception('Error saving animation collection: $e');
    }
  }

  @override
  Future<void> deleteCollection(String collectionId) async {
    try {
      await _collectionRef.doc(collectionId).delete();
    } on FirebaseException catch (e) {
      developer.log(
        'Firebase error deleting collection id=$collectionId: '
        '${e.code} - ${e.message}',
        name: 'AnimationRemoteDatasourceV2',
      );
      throw Exception(
        'Error deleting animation collection: ${e.message}',
      );
    } catch (e) {
      developer.log(
        'Error deleting collection id=$collectionId',
        name: 'AnimationRemoteDatasourceV2',
        error: e,
      );
      throw Exception('Error deleting animation collection: $e');
    }
  }
}
