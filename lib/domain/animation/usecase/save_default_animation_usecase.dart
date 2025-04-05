import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class SaveDefaultAnimationUseCase
    extends UseCase<List<AnimationItemModel>, List<AnimationItemModel>> {
  final AnimationRepository animationRepository;
  SaveDefaultAnimationUseCase({required this.animationRepository});
  @override
  Future<List<AnimationItemModel>> call(param) async {
    return await animationRepository.saveDefaultAnimations(
      animationItems: param,
    );
  }
}
