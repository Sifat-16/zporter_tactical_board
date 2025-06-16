import 'package:zporter_tactical_board/data/animation/model/history_model.dart';
import 'package:zporter_tactical_board/data/animation/repository/animation_repository.dart';
import 'package:zporter_tactical_board/domain/common/usecase.dart';

class SaveHistoryUseCase extends UseCase<void, HistoryModel> {
  final AnimationRepository animationRepository;
  SaveHistoryUseCase({required this.animationRepository});
  @override
  Future<void> call(param) async {
    return await animationRepository.saveHistory(historyModel: param);
  }
}
