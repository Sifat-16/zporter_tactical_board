import 'package:flutter/material.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/animation_panel_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/design_panel_v2.dart';
import 'package:zporter_tactical_board/v2/presentation/panels/right/settings_panel_v2.dart';

/// Right toolbar container with three tabs: Design, Animation, Settings.
///
/// Matches V1's [RightToolbarComponent] layout. Defaults to the
/// Animation tab (initialIndex: 1).
class RightToolbarV2 extends StatefulWidget {
  /// User ID passed through to the animation panel for CRUD.
  final String userId;

  const RightToolbarV2({super.key, required this.userId});

  @override
  State<RightToolbarV2> createState() => _RightToolbarV2State();
}

class _RightToolbarV2State extends State<RightToolbarV2>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Default to Animation tab (index 1), same as V1
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
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
              children: [
                const DesignPanelV2(),
                AnimationPanelV2(userId: widget.userId),
                const SettingsPanelV2(),
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
          Tab(text: 'Design'),
          Tab(text: 'Animation'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }
}
