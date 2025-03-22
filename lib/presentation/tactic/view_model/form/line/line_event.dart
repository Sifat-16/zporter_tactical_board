import 'package:equatable/equatable.dart';
import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';

abstract class LineEvent extends Equatable {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LoadActiveLineModelToAddIntoGameFieldEvent extends LineEvent {
  final FormModel formModel;
  LoadActiveLineModelToAddIntoGameFieldEvent({required this.formModel});
  @override
  List<Object?> get props => [formModel];
}

class UnLoadActiveLineModelToAddIntoGameFieldEvent extends LineEvent {
  final FormModel formModel;
  UnLoadActiveLineModelToAddIntoGameFieldEvent({required this.formModel});
  @override
  List<Object?> get props => [formModel];
}

class DismissActiveLineModelToAddIntoGameFieldEvent extends LineEvent {
  DismissActiveLineModelToAddIntoGameFieldEvent();
  @override
  List<Object?> get props => [];
}
