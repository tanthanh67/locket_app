import 'package:flutter/material.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            ProfileSimpleHeader(
              title: 'Privacy',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 28),
            const _EncryptionNotice(),
            const SizedBox(height: 28),
            const ProfileSectionLabel('WHO CAN SEE ME'),
            const SizedBox(height: 10),
            const ProfileToggleCard(
              rows: [
                ProfileToggleRow(
                  icon: Icons.visibility_rounded,
                  title: 'Profile visibility',
                  subtitle: 'Friends only',
                  showSwitch: false,
                ),
                ProfileToggleRow(
                  icon: Icons.search_rounded,
                  title: 'Findable by username',
                ),
                ProfileToggleRow(
                  icon: Icons.contacts_rounded,
                  title: 'Sync contacts',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ProfileSectionLabel('DATA & MEDIA'),
            const SizedBox(height: 10),
            const ProfileToggleCard(
              rows: [
                ProfileToggleRow(
                  icon: Icons.photo_library_rounded,
                  title: 'Save photos to camera roll',
                  initialValue: false,
                ),
                ProfileToggleRow(
                  icon: Icons.analytics_rounded,
                  title: 'Share usage analytics',
                ),
                ProfileToggleRow(
                  icon: Icons.location_on_rounded,
                  title: 'Location in captions',
                  initialValue: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EncryptionNotice extends StatelessWidget {
  const _EncryptionNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15130C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: const Row(
        children: [
          ProfileSettingIcon(icon: Icons.shield_rounded),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'End-to-end encrypted',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Only your friends can view your photos',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
