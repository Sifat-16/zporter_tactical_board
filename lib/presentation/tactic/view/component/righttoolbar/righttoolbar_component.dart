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

  // List of tab names and content to display
  late List<Map<String, dynamic>> _tabs;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
    _tabs = [
      {'title': 'Design', 'content': DesignToolbarComponent()},
      {
        'title': 'Animation',
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

    // Sync TabBar with PageView swipe
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((t) {
    //   ref
    //       .read(boardProvider.notifier)
    //       .updateTabController(controller: _tabController);
    // });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Container(
            color: ColorManager.black,
            child: TabBar(
              controller: _tabController,
              labelColor: ColorManager.yellow,
              padding: EdgeInsets.zero,
              unselectedLabelColor: ColorManager.white,
              indicatorColor: ColorManager.yellow, // Remove the indicator line
              labelPadding: EdgeInsets.symmetric(
                horizontal: AppSize.s8,
              ), // Remove padding between tab labels
              isScrollable: false,
              dividerHeight: 0,
              tabs:
                  _tabs.map((tab) {
                    return Tab(text: tab['title']);
                  }).toList(),
            ),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(color: ColorManager.black),
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  _tabController.animateTo(index); // Sync TabBar with PageView
                },
                children:
                    _tabs.map((tab) {
                      dynamic type = tab['content'];
                      if (type is Widget) {
                        return type;
                      }
                      return Center(
                        child: Text(
                          tab['content'],
                          style: TextStyle(color: ColorManager.white),
                        ),
                      );
                    }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
