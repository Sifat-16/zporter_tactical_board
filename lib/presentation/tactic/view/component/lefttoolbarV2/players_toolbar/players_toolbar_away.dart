import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/data/tactic/model/player_model.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';

class PlayersToolbarAway extends StatefulWidget {
  const PlayersToolbarAway({super.key});

  @override
  State<PlayersToolbarAway> createState() => _PlayersToolbarAwayState();
}

class _PlayersToolbarAwayState extends State<PlayersToolbarAway>
    with AutomaticKeepAliveClientMixin {
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
          playerType: PlayerType.AWAY,
        );
      });
    });
  }

  initiatePlayers(List<PlayerModel> home) {
    setState(() {
      players = home;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GridView.count(
      crossAxisCount: 3,
      children: [
        ...List.generate(players.length, (index) {
          PlayerModel player = players[index];
          return PlayerComponentV2(playerModel: player);
        }),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
