import 'package:zporter_tactical_board/data/animation/model/animation_collection_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class GetAllAnimationCollectionUseCase
    extends UseCase<List<AnimationCollectionModel>, dynamic> {
  final AnimationRepository animationRepository;
  GetAllAnimationCollectionUseCase({required this.animationRepository});
  @override
  Future<List<AnimationCollectionModel>> call(param) async {
    return await animationRepository.getAllAnimationCollection();
  }
}
