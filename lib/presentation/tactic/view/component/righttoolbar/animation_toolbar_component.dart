import 'package:flutter/cupertino.dart';

class AnimationToolbarComponent extends StatefulWidget {
  const AnimationToolbarComponent({super.key});

  @override
  State<AnimationToolbarComponent> createState() =>
      _AnimationToolbarComponentState();
}

class _AnimationToolbarComponentState extends State<AnimationToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
    // return BlocConsumer<AnimationBloc, AnimationState>(
    //   listener: (BuildContext context, Object? state) {
    //     if(state is AnimationSavedState){
    //       debug(data: "Animation is saved");
    //       setState(() {
    //         animations = state.animations;
    //       });
    //     }
    //   },
    //   builder: (context, state) {
    //     return ListView.builder(
    //         itemCount: animations.length,
    //         itemBuilder: (context, index){
    //           return Container(
    //             margin: EdgeInsets.only(bottom: 10),
    //               child: FieldMiniComponent(itemPosition: animations[index].items));
    //         }
    //     );
    //   },
    // );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
