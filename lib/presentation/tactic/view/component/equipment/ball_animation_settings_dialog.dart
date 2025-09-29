import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/dropdown_selector.dart';
import 'package:zporter_tactical_board/app/extensions/size_extension.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/equipment_model.dart';

class BallAnimationSettingsDialog extends StatefulWidget {
  final EquipmentModel initialBallModel;

  const BallAnimationSettingsDialog({
    super.key,
    required this.initialBallModel,
  });

  @override
  State<BallAnimationSettingsDialog> createState() =>
      _BallAnimationSettingsDialogState();
}

class _BallAnimationSettingsDialogState
    extends State<BallAnimationSettingsDialog> {
  // State variables for all our controls
  late bool _isAerial;
  late double _speedMultiplier;
  late BallSpin _spinType;

  @override
  void initState() {
    super.initState();
    // Initialize state from the ball model passed into the widget
    _isAerial = widget.initialBallModel.isAerialArrival;

    // Set default values if the properties don't exist on the model yet
    _speedMultiplier = widget.initialBallModel.passSpeedMultiplier ?? 1.0;
    _spinType = widget.initialBallModel.spin ?? BallSpin.none;
  }

  void _onSave() {
    // Create a new model instance with all the updated values from our state
    final updatedModel = widget.initialBallModel.copyWith(
      isAerialArrival: _isAerial,
      passSpeedMultiplier: _speedMultiplier,
      spin: _spinType,
    );
    // Return the updated model when popping the dialog
    Navigator.of(context).pop(updatedModel);
  }

  // Helper to make the spin enum look nice in the dropdown
  String _spinToString(BallSpin spin) {
    switch (spin) {
      case BallSpin.none:
        return 'None';
      case BallSpin.left:
        return 'Left';
      case BallSpin.right:
        return 'Right';
      case BallSpin.knuckleball:
        return 'Knuckleball';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      backgroundColor: ColorManager.black,
      title: const Text(
        'Ball animation',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: ColorManager.white,
        ),
      ),
      content: SizedBox(
        width: context.widthPercent(25), // Constrain width like reference
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 20,
          children: [
            // Movement Dropdown (Air/Ground)
            DropdownSelector<String>(
              label: "Movement",
              items: const ['Air', 'Ground'],
              initialValue: _isAerial ? 'Air' : 'Ground',
              onChanged: (value) {
                setState(() {
                  _isAerial = (value == 'Air');
                });
              },
              itemAsString: (item) => item,
            ),
            // Speed Dropdown
            DropdownSelector<double>(
              label: "Speed",
              items: const [0.5, 1.0, 2.0, 3.0],
              initialValue: _speedMultiplier,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _speedMultiplier = value;
                  });
                }
              },
              itemAsString: (speed) => '${speed}x',
            ),
            // Spin Dropdown
            DropdownSelector<BallSpin>(
              label: "Spin",
              items: BallSpin.values,
              initialValue: _spinType,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _spinType = value;
                  });
                }
              },
              itemAsString: _spinToString,
            ),
          ],
        ),
      ),
      actions: [
        // Using Row and CustomButtons to match your reference style
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 10,
          children: [
            CustomButton(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              borderRadius: 2,
              fillColor: ColorManager.dark1,
              child: Text(
                "CANCEL",
                style: TextStyle(color: ColorManager.white),
              ),
              onTap: () {
                Navigator.of(context).pop(null); // Cancel returns null
              },
            ),
            CustomButton(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              borderRadius: 2,
              fillColor: ColorManager.blue,
              onTap: _onSave, // Save returns the updated model
              child: const Text(
                "SAVE",
                style: TextStyle(color: ColorManager.white),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
