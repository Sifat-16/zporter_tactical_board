import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';
import 'package:zporter_tactical_board/presentation/admin/view/animation/default_animation_constants.dart';

class SaveAnimationCollectionUseCase
    extends UseCase<AnimationCollectionModel, AnimationCollectionModel> {
  final AnimationRepository animationRepository;
  SaveAnimationCollectionUseCase({required this.animationRepository});
  @override
  Future<AnimationCollectionModel> call(param) async {
    if (param.id == DefaultAnimationConstants.default_animation_collection_id) {
      return param;
    }
    return await animationRepository.saveAnimationCollection(
      animationCollectionModel: param,
    );
  }
}
