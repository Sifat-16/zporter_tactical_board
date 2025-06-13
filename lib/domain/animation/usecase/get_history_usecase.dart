import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class GetHistoryUseCase extends UseCase<HistoryModel?, String> {
  final AnimationRepository animationRepository;
  GetHistoryUseCase({required this.animationRepository});
  @override
  Future<HistoryModel?> call(param) async {
    return await animationRepository.getHistory(id: param);
  }
}
