// import 'package:flutter/material.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/forms_toolbar_component.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar_component.dart';
//
// import 'equipment_toolbar_component.dart';
//
// class LefttoolbarComponent extends StatefulWidget {
//   const LefttoolbarComponent({super.key, this.showFooter = true});
//   final bool showFooter;
//
//   @override
//   State<LefttoolbarComponent> createState() => _LefttoolbarComponentState();
// }
//
// class _LefttoolbarComponentState extends State<LefttoolbarComponent>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   late PageController _pageController;
//
//   // List of tab names and content to display
//   late List<Map<String, dynamic>> _tabs;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize the TabController
//     _tabs = [
//       {
//         'title': 'Players',
//         'content': PlayersToolbarComponent(showFooter: widget.showFooter),
//       },
//       {'title': 'Forms', 'content': FormsToolbarComponent()},
//       {'title': 'Equipment', 'content': EquipmentToolbarComponent()},
//     ];
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _pageController = PageController();
//
//     // Sync TabBar with PageView swipe
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         _pageController.jumpToPage(_tabController.index);
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _tabController.dispose();
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: Column(
//         children: [
//           Container(
//             color: ColorManager.black,
//             child: TabBar(
//               controller: _tabController,
//               labelColor: ColorManager.yellow,
//               padding: EdgeInsets.zero,
//               unselectedLabelColor: ColorManager.white,
//               tabAlignment: TabAlignment.fill,
//               indicatorColor: ColorManager.yellow, // Remove the indicator line
//               labelPadding:
//                   EdgeInsets.zero, // Remove padding between tab labels
//               isScrollable: false,
//               dividerHeight: 0,
//               tabs: _tabs.map((tab) {
//                 return Tab(text: tab['title']);
//               }).toList(),
//             ),
//           ),
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(color: ColorManager.black),
//               child: PageView(
//                 physics: NeverScrollableScrollPhysics(),
//                 controller: _pageController,
//                 onPageChanged: (index) {
//                   _tabController.animateTo(index); // Sync TabBar with PageView
//                 },
//                 children: _tabs.map((tab) {
//                   dynamic type = tab['content'];
//                   if (type is Widget) {
//                     return type;
//                   }
//                   return Center(
//                     child: Text(
//                       tab['content'],
//                       style: TextStyle(color: ColorManager.white),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart'; // Assuming you need this for AppSize
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/forms_toolbar_component.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar_component.dart';

import 'equipment_toolbar_component.dart';

class LefttoolbarComponent extends StatefulWidget {
  const LefttoolbarComponent({super.key, this.showFooter = true});
  final bool showFooter;

  @override
  State<LefttoolbarComponent> createState() => _LefttoolbarComponentState();
}

class _LefttoolbarComponentState extends State<LefttoolbarComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // List of tab names and content to display
  late List<Map<String, dynamic>> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      {
        'title': 'Players',
        'content': PlayersToolbarComponent(showFooter: widget.showFooter),
      },
      {'title': 'Forms', 'content': FormsToolbarComponent()},
      {'title': 'Equipment', 'content': EquipmentToolbarComponent()},
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();

    // MODIFIED: Combine listeners to rebuild UI and sync PageView
    _tabController.addListener(() {
      // Rebuild the widget to update the custom tab bar's style
      if (mounted) {
        setState(() {});
      }
      // Sync TabBar with PageView swipe
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    // It's good practice to remove the listener before disposing
    _tabController.removeListener(() {});
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- NEW: Custom Tab Bar Widget (copied from the Right Toolbar solution) ---
  Widget _buildCustomTabBar() {
    return Container(
      height: kToolbarHeight, // Standard toolbar height
      color: ColorManager.black.withValues(alpha: 0.5),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final bool isSelected = _tabController.index == index;
          return Expanded(
            // Expanded forces each child to take up an equal amount of space.
            child: InkWell(
              onTap: () {
                _tabController.animateTo(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? ColorManager.yellow : Colors.transparent,
                      width: 2.0, // This is our indicator
                    ),
                  ),
                ),
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSize.s4),
                  child: Text(
                    _tabs[index]['title'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isSelected ? ColorManager.yellow : ColorManager.white,
                    ),
                    // Text will automatically wrap if it's too long
                    softWrap: true,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // --- REPLACED TabBar with our custom implementation ---
        _buildCustomTabBar(),
        // --------------------------------------------------
        Expanded(
          child: Container(
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index); // Sync TabBar with PageView
              },
              children: _tabs.map((tab) {
                return tab['content'] as Widget;
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
