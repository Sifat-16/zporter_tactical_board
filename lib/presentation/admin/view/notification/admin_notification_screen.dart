// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
// import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
// import 'package:zporter_tactical_board/app/manager/color_manager.dart';
// import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
// import 'package:zporter_tactical_board/presentation/admin/view_model/notification/notification_view_model.dart';
//
// class AdminNotificationScreen extends ConsumerStatefulWidget {
//   const AdminNotificationScreen({super.key});
//
//   @override
//   ConsumerState<AdminNotificationScreen> createState() =>
//       _AdminNotificationScreenState();
// }
//
// class _AdminNotificationScreenState
//     extends ConsumerState<AdminNotificationScreen> {
//   final _titleController = TextEditingController();
//   final _bodyController = TextEditingController();
//   String? _selectedTarget;
//
//   @override
//   void dispose() {
//     _titleController.dispose();
//     _bodyController.dispose();
//     super.dispose();
//   }
//
//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: isError ? ColorManager.red : ColorManager.green,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(notificationAdminViewModelProvider);
//     final viewModel = ref.read(notificationAdminViewModelProvider.notifier);
//
//     ref.listen<NotificationAdminState>(notificationAdminViewModelProvider,
//         (previous, next) {
//       if (next.error != null && previous?.error != next.error) {
//         _showSnackBar(next.error!, isError: true);
//       }
//     });
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Send Notifications',
//             style: TextStyle(color: ColorManager.white)),
//         backgroundColor: ColorManager.black,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: ColorManager.white),
//       ),
//       backgroundColor: ColorManager.black,
//       body: state.isLoading && state.sentNotifications.isEmpty
//           ? const Center(child: ZLoader(logoAssetPath: 'assets/image/logo.png'))
//           : Padding(
//               padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: _buildComposerCard(state, viewModel),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     flex: 3,
//                     child: _buildHistoryCard(state),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
//
//   InputDecoration _customInputDecoration({required String labelText}) {
//     return InputDecoration(
//       labelText: labelText,
//       labelStyle: const TextStyle(color: ColorManager.grey),
//       filled: true,
//       fillColor: ColorManager.dark2,
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: ColorManager.dark2),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(8),
//         borderSide: const BorderSide(color: ColorManager.yellow),
//       ),
//     );
//   }
//
//   Widget _buildComposerCard(
//       NotificationAdminState state, NotificationAdminViewModel viewModel) {
//     final dropdownItems = <DropdownMenuItem<String>>[
//       const DropdownMenuItem(
//           value: 'zporter_news', child: Text('Zporter News')),
//       const DropdownMenuItem(
//           value: 'pro_offers', child: Text('Pro Offers Topic')),
//       const DropdownMenuItem(
//           value: 'app_updates', child: Text('App Updates Topic')),
//       // ...state.users
//       //     .where((user) => user.fcmToken != null && user.fcmToken!.isNotEmpty)
//       //     .map((user) {
//       //   return DropdownMenuItem(
//       //     value: user.fcmToken!,
//       //     child: Text('User: ${user.name}'),
//       //   );
//       // }),
//     ];
//
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: ColorManager.dark1,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Compose Message',
//               style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: ColorManager.white),
//             ),
//             const SizedBox(height: 24),
//             TextFormField(
//               controller: _titleController,
//               style: const TextStyle(color: ColorManager.white),
//               decoration: _customInputDecoration(labelText: 'Title'),
//             ),
//             const SizedBox(height: 16),
//             TextFormField(
//               controller: _bodyController,
//               style: const TextStyle(color: ColorManager.white),
//               decoration: _customInputDecoration(labelText: 'Body'),
//               maxLines: 4,
//             ),
//             const SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               value: _selectedTarget,
//               hint: const Text('Select Target Audience',
//                   style: TextStyle(color: ColorManager.grey)),
//               onChanged: (value) {
//                 setState(() => _selectedTarget = value);
//               },
//               items: dropdownItems,
//               decoration: _customInputDecoration(labelText: 'Target'),
//               dropdownColor: ColorManager.dark2,
//               icon: const Icon(Icons.arrow_drop_down, color: ColorManager.grey),
//               style: const TextStyle(color: Colors.white, fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             CustomButton(
//               height: 50,
//               fillColor:
//                   state.isSending ? ColorManager.grey : ColorManager.green,
//               borderRadius: 8,
//               onTap: state.isSending
//                   ? null
//                   : () async {
//                       if (_titleController.text.isEmpty ||
//                           _bodyController.text.isEmpty ||
//                           _selectedTarget == null) {
//                         _showSnackBar(
//                             'Title, body, and target cannot be empty.',
//                             isError: true);
//                         return;
//                       }
//                       final success = await viewModel.sendNotification(
//                         title: _titleController.text,
//                         body: _bodyController.text,
//                         target: _selectedTarget!,
//                       );
//                       if (success) {
//                         _showSnackBar('Notification sent successfully!');
//                         _titleController.clear();
//                         _bodyController.clear();
//                         setState(() => _selectedTarget = null);
//                       }
//                     },
//               child: state.isSending
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                           strokeWidth: 3, color: Colors.white))
//                   : const Text('Send Notification',
//                       style: TextStyle(
//                           color: Colors.white, fontWeight: FontWeight.bold)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHistoryCard(NotificationAdminState state) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: ColorManager.dark1,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           const Text(
//             'Sent History',
//             style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: ColorManager.white),
//           ),
//           const SizedBox(height: 16),
//           Expanded(
//             child: state.sentNotifications.isEmpty
//                 ? const Center(
//                     child: Text('No notifications sent yet.',
//                         style: TextStyle(color: ColorManager.grey)))
//                 : ListView.builder(
//                     itemCount: state.sentNotifications.length,
//                     itemBuilder: (context, index) {
//                       return _SentNotificationTile(
//                           notification: state.sentNotifications[index]);
//                     },
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SentNotificationTile extends StatelessWidget {
//   final SentNotificationModel notification;
//
//   const _SentNotificationTile({required this.notification});
//
//   @override
//   Widget build(BuildContext context) {
//     final isSuccess = notification.status == SentNotificationStatus.success;
//     final targetDisplay = notification.target.length > 40
//         ? '${notification.target.substring(0, 40)}...'
//         : notification.target;
//     final timeFormatted =
//         DateFormat('MMM d, yy HH:mm').format(notification.sentAt);
//
//     return Card(
//       color: ColorManager.dark2,
//       margin: const EdgeInsets.symmetric(vertical: 4),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       elevation: 0,
//       child: ListTile(
//         leading: Icon(
//           isSuccess ? Icons.check_circle : Icons.error,
//           color: isSuccess ? ColorManager.green : ColorManager.red,
//         ),
//         title: Text(notification.title,
//             style: const TextStyle(
//                 fontWeight: FontWeight.bold, color: Colors.white)),
//         subtitle: Tooltip(
//           message: notification.failureReason ?? 'Sent successfully',
//           child: Text(
//             'To: $targetDisplay\n“${notification.body}”',
//             maxLines: 2,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: ColorManager.grey),
//           ),
//         ),
//         trailing: Text(
//           timeFormatted,
//           style: const TextStyle(fontSize: 12, color: ColorManager.grey),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zporter_tactical_board/app/core/component/custom_button.dart';
import 'package:zporter_tactical_board/app/core/component/z_loader.dart';
import 'package:zporter_tactical_board/app/manager/color_manager.dart';
import 'package:zporter_tactical_board/data/admin/model/sent_notification_model.dart';
import 'package:zporter_tactical_board/presentation/admin/view_model/notification/notification_view_model.dart';

class AdminNotificationScreen extends ConsumerStatefulWidget {
  const AdminNotificationScreen({super.key});

  @override
  ConsumerState<AdminNotificationScreen> createState() =>
      _AdminNotificationScreenState();
}

class _AdminNotificationScreenState
    extends ConsumerState<AdminNotificationScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _mediaUrlController = TextEditingController(); // For pasting URLs
  String? _selectedTarget;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorManager.red : ColorManager.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationAdminViewModelProvider);
    final viewModel = ref.read(notificationAdminViewModelProvider.notifier);

    ref.listen<NotificationAdminState>(notificationAdminViewModelProvider,
        (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        _showSnackBar(next.error!, isError: true);
      }
      if (next.mediaError != null && previous?.mediaError != next.mediaError) {
        _showSnackBar(next.mediaError!, isError: true);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notifications',
            style: TextStyle(color: ColorManager.white)),
        backgroundColor: ColorManager.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: ColorManager.white),
      ),
      backgroundColor: ColorManager.black,
      body: state.isLoading && state.sentNotifications.isEmpty
          ? const Center(child: ZLoader(logoAssetPath: 'assets/image/logo.png'))
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildComposerCard(state, viewModel),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: _buildHistoryCard(state),
                  ),
                ],
              ),
            ),
    );
  }

  // A shared input decoration for a consistent look
  InputDecoration _customInputDecoration({required String labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: ColorManager.grey),
      filled: true,
      fillColor: ColorManager.dark2,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorManager.dark2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorManager.yellow),
      ),
    );
  }

  // Main composer card on the left
  Widget _buildComposerCard(
      NotificationAdminState state, NotificationAdminViewModel viewModel) {
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
          value: 'zporter_news', child: Text('Zporter News')),
      const DropdownMenuItem(
          value: 'pro_offers', child: Text('Pro Offers Topic')),
      const DropdownMenuItem(
          value: 'app_updates', child: Text('App Updates Topic')),
    ];

    bool canSend = !state.isSending && !state.isUploadingMedia;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ColorManager.dark1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Compose Message',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.white)),
            const SizedBox(height: 24),
            TextFormField(
                controller: _titleController,
                style: const TextStyle(color: ColorManager.white),
                decoration: _customInputDecoration(labelText: 'Title')),
            const SizedBox(height: 16),
            TextFormField(
                controller: _bodyController,
                style: const TextStyle(color: ColorManager.white),
                decoration: _customInputDecoration(labelText: 'Body'),
                maxLines: 4),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              hint: const Text('Select Target Audience',
                  style: TextStyle(color: ColorManager.grey)),
              onChanged: (value) => setState(() => _selectedTarget = value),
              items: dropdownItems,
              decoration: _customInputDecoration(labelText: 'Target'),
              dropdownColor: ColorManager.dark2,
              icon: const Icon(Icons.arrow_drop_down, color: ColorManager.grey),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            // -- Media Section Begins --
            const Text('Media Gallery',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: ColorManager.white)),
            const SizedBox(height: 12),
            _buildMediaManager(state, viewModel), // Add/upload media
            const SizedBox(height: 12),
            _buildMediaGrid(state, viewModel), // Grid of media
            // -- Media Section Ends --
            const SizedBox(height: 24),
            CustomButton(
              height: 50,
              fillColor: canSend ? ColorManager.green : ColorManager.grey,
              borderRadius: 8,
              onTap: canSend
                  ? () async {
                      if (_titleController.text.isEmpty ||
                          _bodyController.text.isEmpty ||
                          _selectedTarget == null) {
                        _showSnackBar('Title, body, and target are required.',
                            isError: true);
                        return;
                      }
                      if (state.uploadedMediaUrls.isNotEmpty &&
                          state.coverImageUrl == null) {
                        _showSnackBar(
                            'Please select a cover image for the notification.',
                            isError: true);
                        return;
                      }
                      final success = await viewModel.sendNotification(
                        title: _titleController.text,
                        body: _bodyController.text,
                        target: _selectedTarget!,
                      );
                      if (success) {
                        _showSnackBar('Notification sent successfully!');
                        _titleController.clear();
                        _bodyController.clear();
                        _mediaUrlController.clear();
                        setState(() => _selectedTarget = null);
                      }
                    }
                  : null,
              child: state.isSending || state.isUploadingMedia
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 3, color: Colors.white))
                  : const Text('Send Notification',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for adding and uploading media
  Widget _buildMediaManager(
      NotificationAdminState state, NotificationAdminViewModel viewModel) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _mediaUrlController,
                style: const TextStyle(color: ColorManager.white, fontSize: 14),
                decoration:
                    _customInputDecoration(labelText: 'Paste media URL'),
              ),
            ),
            const SizedBox(width: 8),
            CustomButton(
              height: 55,
              // width: 55,
              onTap: () {
                viewModel.addMediaFromUrl(_mediaUrlController.text);
                _mediaUrlController.clear();
              },
              fillColor: ColorManager.dark2,
              child: const Icon(Icons.add_link, color: ColorManager.white),
            )
          ],
        ),
        const SizedBox(height: 8),
        CustomButton(
          height: 45,
          fillColor:
              state.isUploadingMedia ? ColorManager.grey : ColorManager.blue,
          onTap: state.isUploadingMedia ? null : viewModel.selectAndUploadMedia,
          child:
              const Text('Upload Files', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  // Widget to display the grid of uploaded media
  Widget _buildMediaGrid(
      NotificationAdminState state, NotificationAdminViewModel viewModel) {
    if (state.uploadedMediaUrls.isEmpty && !state.isUploadingMedia) {
      return const SizedBox.shrink();
    }
    if (state.isUploadingMedia && state.uploadedMediaUrls.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: ColorManager.dark2,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: state.uploadedMediaUrls.length,
        itemBuilder: (context, index) {
          final url = state.uploadedMediaUrls[index];
          return _MediaThumbnail(
            key: ValueKey(url),
            url: url,
            isCover: url == state.coverImageUrl,
            onRemove: () => viewModel.removeMedia(url),
            onSetCover: () => viewModel.setAsCoverImage(url),
          );
        },
      ),
    );
  }

  // Right-side card showing notification history
  Widget _buildHistoryCard(NotificationAdminState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: ColorManager.dark1,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Sent History',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: ColorManager.white),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: state.sentNotifications.isEmpty
                ? const Center(
                    child: Text('No notifications sent yet.',
                        style: TextStyle(color: ColorManager.grey)))
                : ListView.builder(
                    itemCount: state.sentNotifications.length,
                    itemBuilder: (context, index) {
                      return _SentNotificationTile(
                          notification: state.sentNotifications[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// A single thumbnail in the media grid
class _MediaThumbnail extends StatelessWidget {
  final String url;
  final bool isCover;
  final VoidCallback onRemove;
  final VoidCallback onSetCover;

  const _MediaThumbnail({
    super.key,
    required this.url,
    required this.isCover,
    required this.onRemove,
    required this.onSetCover,
  });

  bool get isVideo =>
      url.toLowerCase().contains('.mp4') || url.toLowerCase().contains('.mov');

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image/Video Icon
          Container(
            color: ColorManager.black,
            child: isVideo
                ? const Icon(Icons.videocam, color: ColorManager.grey, size: 40)
                : CachedNetworkImage(
                    imageUrl: url,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                        child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error, color: ColorManager.red),
                  ),
          ),

          // 2. Click handler for the main area to set the cover image
          Positioned.fill(
            child: InkWell(
              onTap: isVideo ? null : onSetCover,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(isCover ? 0.5 : 0.0),
                  border: Border.all(
                      color: isCover ? ColorManager.green : Colors.transparent,
                      width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: isCover
                    ? const Icon(Icons.check_circle, color: ColorManager.green)
                    : (isVideo || isCover)
                        ? null
                        : Center(
                            // "Set Cover" text only appears if it's not the cover
                            child: Opacity(
                              opacity: 0.8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text('Set Cover',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 10)),
                              ),
                            ),
                          ),
              ),
            ),
          ),

          // 3. Remove Button - Placed last to be on top of everything else
          Positioned(
            top: 4,
            right: 4,
            child: InkWell(
              onTap: onRemove,
              child: const CircleAvatar(
                radius: 12,
                backgroundColor: Colors.black54,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// A single tile in the history list
class _SentNotificationTile extends StatelessWidget {
  final SentNotificationModel notification;

  const _SentNotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isSuccess = notification.status == SentNotificationStatus.success;
    final timeFormatted =
        DateFormat('MMM d, yy HH:mm').format(notification.sentAt);

    return Card(
      color: ColorManager.dark2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: ListTile(
        leading: SizedBox(
          width: 50,
          height: 50,
          child: Stack(
            children: [
              if (notification.coverImageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: CachedNetworkImage(
                    imageUrl: notification.coverImageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              Align(
                alignment: Alignment.bottomRight,
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: ColorManager.dark1,
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.error,
                    size: 18,
                    color: isSuccess ? ColorManager.green : ColorManager.red,
                  ),
                ),
              ),
            ],
          ),
        ),
        title: Text(notification.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Tooltip(
          message: notification.failureReason ?? 'Sent successfully',
          child: Text(
            'To: ${notification.target}\n“${notification.body}”',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: ColorManager.grey),
          ),
        ),
        trailing: Text(
          timeFormatted,
          style: const TextStyle(fontSize: 12, color: ColorManager.grey),
        ),
      ),
    );
  }
}
