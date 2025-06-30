import 'package:zporter_tactical_board/data/animation/model/animation_model.dart'; // Your AnimationModel

abstract class DefaultAnimationRepository {
  Future<List<AnimationModel>> getAllDefaultAnimations();
  Future<AnimationModel> saveDefaultAnimation(AnimationModel animationModel);
  Future<void> deleteDefaultAnimation(String animationId);

  Future<void> saveAllDefaultAnimations(List<AnimationModel> animations);
}
