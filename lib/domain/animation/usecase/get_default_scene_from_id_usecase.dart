import 'package:zporter_tactical_board/data/animation/model/animation_item_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class GetDefaultSceneFromIdUseCase
    extends UseCase<AnimationItemModel?, GetDefaultSceneParam> {
  final AnimationRepository animationRepository;
  GetDefaultSceneFromIdUseCase({required this.animationRepository});
  @override
  Future<AnimationItemModel?> call(param) async {
    return await animationRepository.getDefaultSceneFromId(
      id: param.id,
      userId: param.userId,
    );
  }
}

class GetDefaultSceneParam {
  String id;
  String userId;
  GetDefaultSceneParam({required this.id, required this.userId});
}
