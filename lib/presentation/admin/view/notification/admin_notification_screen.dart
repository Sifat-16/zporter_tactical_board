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
  String? _selectedTarget;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
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

  Widget _buildComposerCard(
      NotificationAdminState state, NotificationAdminViewModel viewModel) {
    final dropdownItems = <DropdownMenuItem<String>>[
      const DropdownMenuItem(
          value: 'zporter_news', child: Text('Zporter News')),
      const DropdownMenuItem(
          value: 'pro_offers', child: Text('Pro Offers Topic')),
      const DropdownMenuItem(
          value: 'app_updates', child: Text('App Updates Topic')),
      ...state.users
          .where((user) => user.fcmToken != null && user.fcmToken!.isNotEmpty)
          .map((user) {
        return DropdownMenuItem(
          value: user.fcmToken!,
          child: Text('User: ${user.name}'),
        );
      }),
    ];

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
            const Text(
              'Compose Message',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorManager.white),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              style: const TextStyle(color: ColorManager.white),
              decoration: _customInputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bodyController,
              style: const TextStyle(color: ColorManager.white),
              decoration: _customInputDecoration(labelText: 'Body'),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedTarget,
              hint: const Text('Select Target Audience',
                  style: TextStyle(color: ColorManager.grey)),
              onChanged: (value) {
                setState(() => _selectedTarget = value);
              },
              items: dropdownItems,
              decoration: _customInputDecoration(labelText: 'Target'),
              dropdownColor: ColorManager.dark2,
              icon: const Icon(Icons.arrow_drop_down, color: ColorManager.grey),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 24),
            CustomButton(
              height: 50,
              fillColor:
                  state.isSending ? ColorManager.grey : ColorManager.green,
              borderRadius: 8,
              onTap: state.isSending
                  ? null
                  : () async {
                      if (_titleController.text.isEmpty ||
                          _bodyController.text.isEmpty ||
                          _selectedTarget == null) {
                        _showSnackBar(
                            'Title, body, and target cannot be empty.',
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
                        setState(() => _selectedTarget = null);
                      }
                    },
              child: state.isSending
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

class _SentNotificationTile extends StatelessWidget {
  final SentNotificationModel notification;

  const _SentNotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    final isSuccess = notification.status == SentNotificationStatus.success;
    final targetDisplay = notification.target.length > 40
        ? '${notification.target.substring(0, 40)}...'
        : notification.target;
    final timeFormatted =
        DateFormat('MMM d, yy HH:mm').format(notification.sentAt);

    return Card(
      color: ColorManager.dark2,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
      child: ListTile(
        leading: Icon(
          isSuccess ? Icons.check_circle : Icons.error,
          color: isSuccess ? ColorManager.green : ColorManager.red,
        ),
        title: Text(notification.title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: Tooltip(
          message: notification.failureReason ?? 'Sent successfully',
          child: Text(
            'To: $targetDisplay\n“${notification.body}”',
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
