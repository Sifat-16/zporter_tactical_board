// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/app/manager/values_manager.dart';
// import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/settings_toolbar_component.dart';
//
// import 'animation_toolbar_component.dart';
// import 'design_toolbar_component.dart';
//
// class RighttoolbarComponent extends ConsumerStatefulWidget {
//   const RighttoolbarComponent({
//     super.key,
//     this.animationToolbarConfig = AnimationToolbarConfig.full,
//   });
//   final AnimationToolbarConfig animationToolbarConfig;
//
//   @override
//   ConsumerState<RighttoolbarComponent> createState() =>
//       _RighttoolbarComponentState();
// }
//
// class _RighttoolbarComponentState extends ConsumerState<RighttoolbarComponent>
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
//       {'title': 'Design', 'content': DesignToolbarComponent()},
//       {
//         'title': 'Animation asdasdasdadd',
//         'content': AnimationToolbarComponent(
//           config: widget.animationToolbarConfig,
//         ),
//       },
//       {'title': 'Settings', 'content': SettingsToolbarComponent()},
//     ];
//     _tabController = TabController(
//       initialIndex: 1,
//       length: _tabs.length,
//       vsync: this,
//     );
//     _pageController = PageController(initialPage: 1);
//
//     // Sync TabBar with PageView swipe
//     _tabController.addListener(() {
//       if (_tabController.indexIsChanging) {
//         _pageController.jumpToPage(_tabController.index);
//       }
//     });
//
//     // WidgetsBinding.instance.addPostFrameCallback((t) {
//     //   ref
//     //       .read(boardProvider.notifier)
//     //       .updateTabController(controller: _tabController);
//     // });
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
//
//               padding: EdgeInsets.zero,
//               unselectedLabelColor: ColorManager.white,
//               indicatorColor: ColorManager.yellow, // Remove the indicator line
//               labelPadding: EdgeInsets.symmetric(
//                 horizontal: AppSize.s8,
//               ), // Remove padding between tab labels
//               isScrollable: false,
//               tabAlignment: TabAlignment.fill,
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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/righttoolbar/settings_toolbar_component.dart';

import 'animation_toolbar_component.dart';
import 'design_toolbar_component.dart';

class RighttoolbarComponent extends ConsumerStatefulWidget {
  const RighttoolbarComponent({
    super.key,
    this.animationToolbarConfig = AnimationToolbarConfig.full,
  });
  final AnimationToolbarConfig animationToolbarConfig;

  @override
  ConsumerState<RighttoolbarComponent> createState() =>
      _RighttoolbarComponentState();
}

class _RighttoolbarComponentState extends ConsumerState<RighttoolbarComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  late List<Map<String, dynamic>> _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = [
      {'title': 'Design', 'content': DesignToolbarComponent()},
      {
        'title': 'Animation', // Example of long text
        'content': AnimationToolbarComponent(
          config: widget.animationToolbarConfig,
        ),
      },
      {'title': 'Settings', 'content': SettingsToolbarComponent()},
    ];
    _tabController = TabController(
      initialIndex: 1,
      length: _tabs.length,
      vsync: this,
    );
    _pageController = PageController(initialPage: 1);

    // Add a listener to rebuild the UI when the tab changes,
    // so our custom tab bar can update its styles.
    _tabController.addListener(() {
      if (mounted) {
        setState(() {}); // Rebuild to update selected tab style
      }
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    // It's important to remove the listener before disposing the controller.
    _tabController.removeListener(() {});
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // --- NEW: Custom Tab Bar Widget ---
  Widget _buildCustomTabBar() {
    return Container(
      height: kToolbarHeight, // Standard toolbar height
      color: ColorManager.black.withValues(alpha: 0.7),
      child: Row(
        // The Row itself doesn't scroll, but the content inside each tab can wrap.
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
                    textAlign: TextAlign.center, // Center text if it wraps
                    style: TextStyle(
                      color:
                          isSelected ? ColorManager.yellow : ColorManager.white,
                    ),
                    // Text will automatically wrap to a new line if it's too long
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
            decoration:
                BoxDecoration(color: ColorManager.black.withValues(alpha: 0.7)),
            child: PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: _pageController,
              onPageChanged: (index) {
                _tabController.animateTo(index);
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
