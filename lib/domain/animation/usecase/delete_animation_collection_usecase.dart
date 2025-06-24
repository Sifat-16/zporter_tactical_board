import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';

class DeleteAnimationCollectionUseCase {
  final AnimationRepository repository;

  DeleteAnimationCollectionUseCase({required this.repository});

  /// Executes the deletion of an animation collection by its ID.
  ///
  /// This method calls the repository to remove the specified collection
  /// from both the remote and local datasources.
  Future<void> call(String collectionId) async {
    // The use case's job is to simply call the repository method.
    // All the complex logic (offline/online handling, remote vs local)
    // is already handled within the repository implementation.
    return await repository.deleteAnimationCollection(
        collectionId: collectionId);
  }
}
