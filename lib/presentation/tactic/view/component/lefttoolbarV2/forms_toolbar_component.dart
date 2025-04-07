// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/data/tactic/model/form_model.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_item.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/form/form_utils.dart';
//
// class FormsToolbarComponent extends StatefulWidget {
//   const FormsToolbarComponent({super.key});
//
//   @override
//   State<FormsToolbarComponent> createState() => _FormsToolbarComponentState();
// }
//
// class _FormsToolbarComponentState extends State<FormsToolbarComponent>
//     with AutomaticKeepAliveClientMixin {
//   List<FormModel> forms = [];
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((t) {
//       setupForms();
//     });
//   }
//
//   setupForms() {
//     setState(() {
//       forms = FormUtils.generateForms();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//
//     return GridView.count(
//       crossAxisCount: 3,
//       children: List.generate(forms.length, (index) {
//         return FormItem(formModel: forms[index]);
//       }),
//     );
//   }
//
//   @override
//   // TODO: implement wantKeepAlive
//   bool get wantKeepAlive => true;
// }
