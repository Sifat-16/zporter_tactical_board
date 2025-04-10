import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class DeleteHistoryUseCase extends UseCase<void, String> {
  final AnimationRepository animationRepository;
  DeleteHistoryUseCase({required this.animationRepository});
  @override
  Future<void> call(param) async {
    return await animationRepository.deleteHistory(id: param);
  }
}
