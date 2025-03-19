import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_away.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_home.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar/players_toolbar_other.dart';

class PlayersToolbarComponent extends StatefulWidget {
  const PlayersToolbarComponent({super.key});

  @override
  State<PlayersToolbarComponent> createState() =>
      _PlayersToolbarComponentState();
}

class _PlayersToolbarComponentState extends State<PlayersToolbarComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // List of tab names and content to display
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Home', 'content': PlayersToolbarHome()},
    {'title': 'Other', 'content': PlayersToolbarOther()},
    {'title': 'Away', 'content': PlayersToolbarAway()},
  ];

  @override
  void initState() {
    super.initState();
    // Initialize the TabController
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
      decoration: BoxDecoration(
        color: ColorManager.grey.withValues(alpha: 0.1),
      ),
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
              isScrollable: true,
              dividerHeight: 0,
              tabs:
                  _tabs.map((tab) {
                    return Tab(text: tab['title']);
                  }).toList(),
            ),
          ),
          _buildHeader(),

          Container(
            child: Expanded(
              child: PageView(
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "0 Players",
          style: Theme.of(
            context,
          ).textTheme.labelLarge!.copyWith(color: ColorManager.grey),
        ),
        Row(
          children: [
            Icon(Icons.search, color: ColorManager.grey),
            Icon(Icons.arrow_drop_down_outlined, color: ColorManager.grey),
            Icon(Icons.filter_list_outlined, color: ColorManager.grey),
          ],
        ),
      ],
    );
  }
}
