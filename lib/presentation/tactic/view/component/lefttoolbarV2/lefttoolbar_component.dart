import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/app/manager/values_manager.dart';
import 'package:zporter_tactical_board/presentation/tactic/view/component/lefttoolbarV2/players_toolbar_component.dart';

import 'equipment_toolbar_component.dart';
import 'forms_toolbar_component.dart';

class LefttoolbarComponent extends StatefulWidget {
  const LefttoolbarComponent({super.key});

  @override
  State<LefttoolbarComponent> createState() => _LefttoolbarComponentState();
}

class _LefttoolbarComponentState extends State<LefttoolbarComponent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;

  // List of tab names and content to display
  final List<Map<String, dynamic>> _tabs = [
    {'title': 'Players', 'content': PlayersToolbarComponent()},
    {'title': 'Forms', 'content': FormsToolbarComponent()},
    {'title': 'Equipment', 'content': EquipmentToolbarComponent()},
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
      child: Column(
        children: [
          TabBar(
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

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: ColorManager.grey.withValues(alpha: 0.1),
              ),
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
}
