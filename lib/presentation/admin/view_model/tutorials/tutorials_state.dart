import 'package:zporter_tactical_board/data/admin/model/tutorial_model.dart';

enum TutorialStatus { initial, loading, success, error, uploading }

class TutorialsState {
  final TutorialStatus status;
  final List<Tutorial> tutorials;
  final String? errorMessage;

  const TutorialsState({
    this.status = TutorialStatus.initial,
    this.tutorials = const [],
    this.errorMessage,
  });

  TutorialsState copyWith({
    TutorialStatus? status,
    List<Tutorial>? tutorials,
    String? errorMessage,
  }) {
    return TutorialsState(
      status: status ?? this.status,
      tutorials: tutorials ?? this.tutorials,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
