import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SavedAnimationToolbarComponent extends StatefulWidget {
  const SavedAnimationToolbarComponent({super.key});

  @override
  State<SavedAnimationToolbarComponent> createState() =>
      _SavedAnimationToolbarComponentState();
}

class _SavedAnimationToolbarComponentState
    extends State<SavedAnimationToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  // List<AnimationDataModel> animations = [];

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   context.read<AnimationBloc>().add(AnimationUpdateEvent());
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
    // return BlocConsumer<AnimationBloc, AnimationState>(
    //   listener: (BuildContext context, Object? state) {
    //     if(state is AnimationUpdateState){
    //       debug(data: "Animation is saved");
    //       AnimationBloc animationBloc = context.read<AnimationBloc>();
    //       setState(() {
    //         animations = animationBloc.animationDataModel;
    //       });
    //     }
    //   },
    //   builder: (context, state) {
    //     return ListView.builder(
    //       itemCount: animations.length,
    //         itemBuilder: (context, index){
    //       return Container(
    //         margin: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
    //         decoration: BoxDecoration(
    //           border: Border.all(color: ColorManager.dark1),
    //           borderRadius: BorderRadius.circular(10)
    //         ),
    //         child: ExpansionTile(
    //           backgroundColor: ColorManager.grey,
    //
    //           title: Text("Animation ${index+1}", style: Theme.of(context).textTheme.labelLarge!.copyWith(
    //             color: ColorManager.white
    //           ),),
    //           trailing: IconButton(onPressed: (){
    //
    //             _playAnimation(animations[index].items);
    //
    //           }, icon: Icon(Icons.play_circle_outline, color: ColorManager.green,)),
    //         ),
    //       );
    //     });
    //   },
    // );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  // void _playAnimation(List<AnimationModel> animations){
  //   showGeneralDialog(
  //     context: context,
  //     barrierColor: Colors.black12.withOpacity(0.6), // Background color
  //     barrierDismissible: false,
  //     barrierLabel: 'Dialog',
  //     transitionDuration: Duration(milliseconds: 400),
  //     pageBuilder: (context, __, ___) {
  //       return Column(
  //         children: <Widget>[
  //           Expanded(
  //             flex: 5,
  //             child: AnimationPlayComponent(animations: animations),
  //           ),
  //           ElevatedButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: Text('Dismiss'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
