import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/left/equipment_panel_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/left/forms_panel_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/left/players_panel_v2.dart';

/// Left toolbar container with three tabs: Players, Forms, Equipment.
///
/// Matches V1's [LeftToolbarComponent] layout and tab structure.
class LeftToolbarV2 extends StatefulWidget {
  const LeftToolbarV2({super.key});

  @override
  State<LeftToolbarV2> createState() => _LeftToolbarV2State();
}

class _LeftToolbarV2State extends State<LeftToolbarV2>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                PlayersPanelV2(),
                FormsPanelV2(),
                EquipmentPanelV2(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: TabBar(
        controller: _tabController,
        indicatorColor: Colors.amber,
        indicatorWeight: 2,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        tabs: const [
          Tab(text: 'Players'),
          Tab(text: 'Forms'),
          Tab(text: 'Equipment'),
        ],
      ),
    );
  }
}
