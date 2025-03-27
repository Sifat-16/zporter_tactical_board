import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/field/field_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class EquipmentComponent extends FieldComponent<EquipmentModel> {
  EquipmentComponent({required super.object});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await game.loadSprite("${object.imagePath}");
    size = Vector2(AppSize.s32, AppSize.s32);
    position = object.offset ?? Vector2(x, y);
    angle = object.angle ?? 0;
    tint(ColorManager.white);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    object.offset = position;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // TODO: implement onTapDown
    super.onTapDown(event);
    ref
        .read(boardProvider.notifier)
        .toggleSelectItemEvent(fieldItemModel: object);
  }

  @override
  void onScaleUpdate(DragUpdateEvent event) {
    super.onScaleUpdate(event);
    object.offset = position;
  }

  @override
  void onRotationUpdate() {
    super.onRotationUpdate();
    object.angle = angle;
  }
}
