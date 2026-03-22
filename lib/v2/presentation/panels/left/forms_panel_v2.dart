import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/generator/random_generator.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/line_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/shape_utils.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/form/components/text/text_field_utils.dart';
import 'package:zporter_tactical_board/v2/models/board_element.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/line_element.dart';
import 'package:zporter_tactical_board/v2/models/shape_elements.dart';
import 'package:zporter_tactical_board/v2/models/text_element.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Forms toolbar panel: lines, shapes, and text tools.
///
/// Uses tap-to-add (not drag-to-board). On tap, creates a V2 element
/// at the center of the board and calls [boardNotifier.addElement()].
class FormsPanelV2 extends ConsumerWidget {
  const FormsPanelV2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        _SectionHeader(title: 'Player Movements'),
        _buildLineGrid(context, ref, _playerMovementLines()),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Ball Movements'),
        _buildLineGrid(context, ref, _ballMovementLines()),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Shapes'),
        _buildShapeGrid(context, ref),
        const SizedBox(height: 12),
        _SectionHeader(title: 'Text'),
        _buildTextTile(context, ref),
      ],
    );
  }

  /// Filter lines into player movement category.
  List<_LineInfo> _playerMovementLines() {
    final lines = LineUtils.generateLines();
    return lines
        .where((l) => [
              LineType.WALK_ONE_WAY,
              LineType.WALK_TWO_WAY,
              LineType.JOG_ONE_WAY,
              LineType.JOG_TWO_WAY,
              LineType.SPRINT_ONE_WAY,
              LineType.SPRINT_TWO_WAY,
              LineType.JUMP,
            ].contains(LineType.fromString(l.lineType.name)))
        .map((l) => _LineInfo(
              name: l.name,
              imagePath: l.imagePath,
              lineType: LineType.fromString(l.lineType.name),
              thickness: l.thickness,
            ))
        .toList();
  }

  /// Filter lines into ball movement category.
  List<_LineInfo> _ballMovementLines() {
    final lines = LineUtils.generateLines();
    return lines
        .where((l) => [
              LineType.PASS,
              LineType.PASS_HIGH_CROSS,
              LineType.DRIBBLE,
              LineType.SHOOT,
            ].contains(LineType.fromString(l.lineType.name)))
        .map((l) => _LineInfo(
              name: l.name,
              imagePath: l.imagePath,
              lineType: LineType.fromString(l.lineType.name),
              thickness: l.thickness,
            ))
        .toList();
  }

  Widget _buildLineGrid(
    BuildContext context,
    WidgetRef ref,
    List<_LineInfo> lines,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: lines.map((info) {
        return _FormTile(
          imagePath: info.imagePath,
          label: info.name,
          onTap: () => _addLine(ref, info),
        );
      }).toList(),
    );
  }

  void _addLine(WidgetRef ref, _LineInfo info) {
    final element = LineElement(
      id: RandomGenerator.generateId(),
      start: const Offset(0.4, 0.5),
      end: const Offset(0.6, 0.5),
      lineType: info.lineType,
      name: info.name,
      imagePath: info.imagePath,
      thickness: info.thickness,
      offset: const Offset(0.5, 0.5),
    );
    ref.read(boardProviderV2.notifier).addElement(element);
  }

  Widget _buildShapeGrid(BuildContext context, WidgetRef ref) {
    final shapes = ShapeUtils.generateShapes();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: shapes.map((shape) {
        return _FormTile(
          imagePath: shape.imagePath,
          label: shape.name,
          onTap: () => _addShape(ref, shape.name, shape.imagePath),
        );
      }).toList(),
    );
  }

  void _addShape(WidgetRef ref, String name, String imagePath) {
    final id = RandomGenerator.generateId();
    final center = const Offset(0.5, 0.5);

    BoardElement element;
    if (name == 'CIRCLE') {
      element = CircleElement(
        id: id,
        center: center,
        radius: 0.05,
        name: name,
        imagePath: imagePath,
      );
    } else if (name == 'SQUARE') {
      element = SquareElement(
        id: id,
        center: center,
        side: 0.1,
        name: name,
        imagePath: imagePath,
      );
    } else {
      // Polygon (triangle or free polygon)
      element = PolygonElement(
        id: id,
        center: center,
        relativeVertices: const [],
        name: name,
        imagePath: imagePath,
      );
    }

    ref.read(boardProviderV2.notifier).addElement(element);
  }

  Widget _buildTextTile(BuildContext context, WidgetRef ref) {
    return _FormTile(
      imagePath: 'text.png',
      label: 'TEXT',
      onTap: () => _addText(context, ref),
    );
  }

  Future<void> _addText(BuildContext context, WidgetRef ref) async {
    // Show text input dialog (reuses V1 utility)
    final v1Text = await TextFieldUtils.insertTextDialog(context);
    if (v1Text == null) return;

    final element = TextElement(
      id: RandomGenerator.generateId(),
      text: v1Text.text,
      name: 'TEXT',
      imagePath: 'text.png',
      offset: const Offset(0.5, 0.5),
      color: Colors.white,
    );

    ref.read(boardProviderV2.notifier).addElement(element);
  }
}

/// Internal line info for categorization.
class _LineInfo {
  final String name;
  final String imagePath;
  final LineType lineType;
  final double thickness;

  const _LineInfo({
    required this.name,
    required this.imagePath,
    required this.lineType,
    this.thickness = 2.0,
  });
}

/// Reusable tile for form tools (lines, shapes, text).
class _FormTile extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _FormTile({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.white10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: Image.asset(
                'assets/images/$imagePath',
                color: Colors.white,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.edit,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header for form categories.
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
