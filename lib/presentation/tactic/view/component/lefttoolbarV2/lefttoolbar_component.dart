import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
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
    // Initialize the TabController
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
      child: Column(
        children: [
          TabBar(
            controller: _tabController,

            labelColor: ColorManager.yellow,

            padding: EdgeInsets.zero,
            unselectedLabelColor: ColorManager.white,
            tabAlignment: TabAlignment.fill,
            indicatorColor: ColorManager.yellow, // Remove the indicator line
            labelPadding: EdgeInsets.zero, // Remove padding between tab labels
            isScrollable: false,
            dividerHeight: 0,
            tabs:
                _tabs.map((tab) {
                  return Tab(text: tab['title']);
                }).toList(),
          ),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorManager.grey.withValues(alpha: 0.1),
              ),
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
