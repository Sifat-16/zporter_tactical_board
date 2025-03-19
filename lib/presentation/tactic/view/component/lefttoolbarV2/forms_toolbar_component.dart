import 'package:flutter/material.dart';

class FormsToolbarComponent extends StatefulWidget {
  const FormsToolbarComponent({super.key});

  @override
  State<FormsToolbarComponent> createState() => _FormsToolbarComponentState();
}

class _FormsToolbarComponentState extends State<FormsToolbarComponent>
    with AutomaticKeepAliveClientMixin {
  // List<FormDataModel> forms = [];
  //
  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   context.read<FormBloc>().add(
  //     FormLoadEvent(forms: FormUtils.generateFormModelList()),
  //   );
  // }
  //
  // initiateForms(List<FormDataModel> fr) {
  //   setState(() {
  //     forms = fr;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
    // return BlocListener<FormBloc, fs.FormState>(
    //   listener: (context, state) {
    //     if (state is fs.FormLoadedState) {
    //       initiateForms(state.forms);
    //     }
    //   },
    //   child: BlocBuilder<FormBloc, fs.FormState>(
    //     buildWhen: (previous, current) => current is fs.FormLoadedState,
    //     builder: (context, state) {
    //       return GridView.count(
    //         crossAxisCount: 3,
    //         children: List.generate(forms.length, (index) {
    //           return FormComponent(formDataModel: forms[index]);
    //         }),
    //       );
    //     },
    //   ),
    // );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
