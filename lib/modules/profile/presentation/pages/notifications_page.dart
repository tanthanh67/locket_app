import 'package:flutter/material.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            ProfileSimpleHeader(
              title: 'Notifications',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 28),
            const ProfileToggleCard(
              rows: [
                ProfileStoredToggleRow(
                  icon: Icons.notifications_rounded,
                  title: 'Push notifications',
                  subtitle: 'Enabled in iOS settings',
                  settingPath: 'notificationSettings.pushNotifications',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ProfileSectionLabel('WHAT TO NOTIFY ME ABOUT'),
            const SizedBox(height: 10),
            const ProfileToggleCard(
              rows: [
                ProfileStoredToggleRow(
                  icon: Icons.photo_rounded,
                  title: 'New photos',
                  settingPath: 'notificationSettings.newPhotos',
                ),
                ProfileStoredToggleRow(
                  icon: Icons.favorite_rounded,
                  title: 'Reactions',
                  settingPath: 'notificationSettings.reactions',
                ),
                ProfileStoredToggleRow(
                  icon: Icons.chat_bubble_rounded,
                  title: 'Replies & chats',
                  settingPath: 'notificationSettings.repliesAndChats',
                ),
                ProfileStoredToggleRow(
                  icon: Icons.person_add_alt_1_rounded,
                  title: 'Friend requests',
                  settingPath: 'notificationSettings.friendRequests',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ProfileSectionLabel('QUIET HOURS'),
            const SizedBox(height: 10),
            const ProfileToggleCard(
              rows: [
                ProfileStoredToggleRow(
                  icon: Icons.nightlight_round,
                  title: 'Do not disturb',
                  settingPath: 'notificationSettings.doNotDisturb',
                  defaultValue: false,
                ),
                ProfileToggleRow(
                  icon: Icons.schedule_rounded,
                  title: 'Schedule',
                  trailing: '22:00 - 07:30',
                  showSwitch: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
