import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class GetHistoryStreamUseCase extends StreamUseCase<HistoryModel?, String> {
  final AnimationRepository animationRepository;
  GetHistoryStreamUseCase({required this.animationRepository});
  @override
  Stream<HistoryModel?> call(param) {
    return animationRepository.getHistoryStream(id: param);
  }
}
