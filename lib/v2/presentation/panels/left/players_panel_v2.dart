import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart' as v1;
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/v2/models/enums.dart';
import 'package:zporter_tactical_board/v2/models/player_element.dart';
import 'package:zporter_tactical_board/v2/presentation/widgets/draggable_board_tile_v2.dart';
import 'package:zporter_tactical_board/v2/state/board_provider.dart';

/// Players sub-tab type for the players panel.
enum _PlayerTab { home, away, other }

/// Player toolbar panel with Home / Away / Other sub-tabs.
///
/// Loads players from [PlayerUtilsV2] (Sembast DB with static fallback),
/// converts V1 [PlayerModel] → V2 [PlayerElement] for drag-to-board.
/// Filters out players already on the board.
class PlayersPanelV2 extends ConsumerStatefulWidget {
  const PlayersPanelV2({super.key});

  @override
  ConsumerState<PlayersPanelV2> createState() => _PlayersPanelV2State();
}

class _PlayersPanelV2State extends ConsumerState<PlayersPanelV2> {
  _PlayerTab _selectedTab = _PlayerTab.home;
  List<v1.PlayerModel> _homePlayers = [];
  List<v1.PlayerModel> _awayPlayers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlayers();
  }

  Future<void> _loadPlayers() async {
    try {
      final home = await PlayerUtilsV2.getOrInitializeHomePlayers();
      final away = await PlayerUtilsV2.getOrInitializeAwayPlayers();
      if (mounted) {
        setState(() {
          _homePlayers = home;
          _awayPlayers = away;
          _isLoading = false;
        });
      }
    } catch (_) {
      // Fallback to static generation
      if (mounted) {
        setState(() {
          _homePlayers = PlayerUtilsV2.generatePlayerModelList(
              playerType: v1.PlayerType.HOME);
          _awayPlayers = PlayerUtilsV2.generatePlayerModelList(
              playerType: v1.PlayerType.AWAY);
          _isLoading = false;
        });
      }
    }
  }

  List<v1.PlayerModel> get _otherPlayers =>
      PlayerUtilsV2.generatePlayerModelList(playerType: v1.PlayerType.OTHER);

  @override
  Widget build(BuildContext context) {
    final boardState = ref.watch(boardProviderV2);
    final onBoardIds = boardState.components.map((e) => e.id).toSet();

    return Column(
      children: [
        _buildSubTabs(),
        const SizedBox(height: 8),
        Expanded(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : _buildPlayerGrid(onBoardIds),
        ),
      ],
    );
  }

  Widget _buildSubTabs() {
    return Row(
      children: _PlayerTab.values.map((tab) {
        final isSelected = tab == _selectedTab;
        final label = switch (tab) {
          _PlayerTab.home => 'Home',
          _PlayerTab.away => 'Away',
          _PlayerTab.other => 'Other',
        };
        return Expanded(
          child: InkWell(
            onTap: () => setState(() => _selectedTab = tab),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? Colors.amber : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayerGrid(Set<String> onBoardIds) {
    final List<v1.PlayerModel> players = switch (_selectedTab) {
      _PlayerTab.home => _homePlayers,
      _PlayerTab.away => _awayPlayers,
      _PlayerTab.other => _otherPlayers,
    };

    // Filter out players already on board
    final available =
        players.where((p) => !onBoardIds.contains(p.id)).toList();

    if (available.isEmpty) {
      return const Center(
        child: Text(
          'All players on board',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: available.length,
      itemBuilder: (context, index) {
        final player = available[index];
        final element = _toPlayerElement(player);
        return DraggableBoardTileV2(
          element: element,
          child: _PlayerTile(player: player),
        );
      },
    );
  }

  /// Convert V1 [PlayerModel] → V2 [PlayerElement] for drag data.
  PlayerElement _toPlayerElement(v1.PlayerModel player) {
    return PlayerElement(
      id: player.id,
      role: player.role,
      jerseyNumber: player.jerseyNumber,
      displayNumber: player.displayNumber,
      playerType: PlayerType.fromString(player.playerType.name),
      name: player.name,
      borderColor: player.borderColor ?? player.color,
      imagePath: player.imagePath,
      imageBase64: player.imageBase64,
      size: const Size(32, 32),
    );
  }
}

/// Visual tile for a player in the toolbar grid.
class _PlayerTile extends StatelessWidget {
  final v1.PlayerModel player;

  const _PlayerTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final color = player.borderColor ?? player.color ?? ColorManager.grey;
    final number = player.displayNumber ?? player.jerseyNumber;
    final showNumber = number > 0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              showNumber ? '$number' : '-',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          player.role,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
