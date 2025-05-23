import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_away.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_home.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_other.dart';

class PlayersToolbarComponent extends StatefulWidget {
  const PlayersToolbarComponent({super.key, this.showFooter = true});
  final bool showFooter;

  @override
  State<PlayersToolbarComponent> createState() =>
      _PlayersToolbarComponentState();
}

class _PlayersToolbarComponentState extends State<PlayersToolbarComponent>
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
      {
        'title': 'Home',
        'content': PlayersToolbarHome(showFooter: widget.showFooter),
      },
      {'title': 'Other', 'content': PlayersToolbarOther()},
      {
        'title': 'Away',
        'content': PlayersToolbarAway(showFooter: widget.showFooter),
      },
    ];
    _tabController = TabController(length: _tabs.length, vsync: this);
    _pageController = PageController();

    // Sync TabBar with PageView swipe
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.jumpToPage(_tabController.index);
      }
    });
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
      padding: EdgeInsets.symmetric(
        vertical: AppSize.s2,
        horizontal: AppSize.s4,
      ),
      decoration: BoxDecoration(color: ColorManager.black),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
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

          // SizedBox(height: AppSize.s8), // Add some space if needed
          Expanded(
            // Ensure PageView gets available space
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
        ],
      ),
    );
  }
}
