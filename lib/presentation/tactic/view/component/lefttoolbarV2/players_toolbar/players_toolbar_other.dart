import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_component_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_model_v2.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/playerV2/player_utils_v2.dart';

class PlayersToolbarOther extends StatefulWidget {
  const PlayersToolbarOther({super.key});

  @override
  State<PlayersToolbarOther> createState() => _PlayersToolbarOtherState();
}

class _PlayersToolbarOtherState extends State<PlayersToolbarOther>
    with AutomaticKeepAliveClientMixin {
  List<PlayerModelV2> players = [];

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

  initiatePlayers(List<PlayerModelV2> home) {
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
          PlayerModelV2 player = players[index];
          return PlayerComponentV2(playerModelV2: player);
        }),
      ],
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
