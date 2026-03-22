/// V2 Tactical Board — single import for all public APIs.
///
/// Usage:
/// ```dart
/// import 'package:zporter_tactical_board/v2/v2.dart';
/// ```
library;

// Models
export 'models/animation_collection.dart';
export 'models/animation_model.dart';
export 'models/board_element.dart';
export 'models/enums.dart';
export 'models/equipment_element.dart';
export 'models/free_draw_element.dart';
export 'models/line_element.dart';
export 'models/player_element.dart';
export 'models/scene_model.dart';
export 'models/shape_elements.dart';
export 'models/text_element.dart';
export 'models/trajectory_model.dart';

// Commands
export 'commands/board_command.dart';
export 'commands/element_commands.dart';

// State
export 'state/board_state.dart';
export 'state/board_notifier.dart';
export 'state/board_provider.dart';
export 'state/animation_notifier.dart';
export 'state/animation_provider.dart';
export 'state/collection_notifier.dart';
export 'state/collection_provider.dart';

// Presentation
export 'presentation/board_widget.dart';
export 'presentation/animated_board_widget.dart';
export 'presentation/screen/tacticboard_screen_v2.dart';
export 'presentation/screen/board_shell_v2.dart';
export 'presentation/widgets/board_drop_zone_v2.dart';
export 'presentation/widgets/draggable_board_tile_v2.dart';
export 'presentation/widgets/panel_toggle_button.dart';

// Core
export 'core/coordinate_system.dart';

// Data — public interfaces
export 'data/repositories/animation_repository_v2.dart';
export 'data/datasources/animation_datasource_v2.dart';
export 'data/repositories/animation_cache_repository_v2.dart';
export 'data/datasources/local/animation_local_datasource_v2.dart';
export 'data/datasources/remote/animation_remote_datasource_v2.dart';

// Adapters
export 'data/adapters/v1_adapter.dart';
