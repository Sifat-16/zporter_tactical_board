import 'package:zporter_tactical_board/data/admin/datasource/default_animation_datasource.dart'; // The new datasource interface
import 'package:zporter_tactical_board/data/animation/model/animation_model.dart';

import 'default_animation_repository.dart';

class DefaultAnimationRepositoryImpl implements DefaultAnimationRepository {
  final DefaultAnimationDatasource datasource;

  DefaultAnimationRepositoryImpl({required this.datasource});

  @override
  Future<List<AnimationModel>> getAllDefaultAnimations() async {
    return datasource.getAllDefaultAnimations();
  }

  @override
  Future<AnimationModel> saveDefaultAnimation(
    AnimationModel animationModel,
  ) async {
    return datasource.saveDefaultAnimation(animationModel);
  }

  @override
  Future<void> deleteDefaultAnimation(String animationId) async {
    return datasource.deleteDefaultAnimation(animationId);
  }
}
