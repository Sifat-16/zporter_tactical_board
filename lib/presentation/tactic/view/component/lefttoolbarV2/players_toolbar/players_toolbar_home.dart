import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view_model/board/board_provider.dart';

class PlayersToolbarHome extends ConsumerStatefulWidget {
  const PlayersToolbarHome({super.key});

  @override
  ConsumerState<PlayersToolbarHome> createState() => _PlayersToolbarHomeState();
}

class _PlayersToolbarHomeState extends ConsumerState<PlayersToolbarHome> {
  List<PlayerModel> players = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initiatePlayerLocally();
    // context.read<PlayerBloc>().add(PlayerTypeLoadEvent(playerType: PlayerType.HOME));
  }

  initiatePlayerLocally() {
    WidgetsBinding.instance.addPostFrameCallback((t) {
      setState(() {
        players = PlayerUtilsV2.generatePlayerModelList(
          playerType: PlayerType.HOME,
        );
      });
    });
  }

  initiatePlayers(List<PlayerModel> home) {
    setState(() {
      players = home;
    });
  }

  List<PlayerModel> generateActivePlayers({
    required List<PlayerModel> players,
    required List<PlayerModel> fieldPlayers,
  }) {
    List<PlayerModel> duplicatePlayers = List.from(players);
    for (var f in fieldPlayers) {
      if (f.playerType == PlayerType.HOME) {
        duplicatePlayers.removeWhere((p) => p.id == f.id);
      }
    }
    return duplicatePlayers;
  }

  @override
  Widget build(BuildContext context) {
    final bp = ref.watch(boardProvider);

    List<PlayerModel> updatedPlayers = generateActivePlayers(
      players: players,
      fieldPlayers: bp.players,
    );

    return GridView.count(
      crossAxisCount: 3,
      children: [
        ...List.generate(updatedPlayers.length, (index) {
          PlayerModel player = updatedPlayers[index];
          return PlayerComponentV2(playerModel: player);
        }),
      ],
    );
  }
}
