import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/auth/presentation/application/cubit/auth_cubit.dart';
import 'package:locket_app/modules/feed/presentation/data/feed_items.dart';
import 'package:locket_app/modules/feed/presentation/application/cubit/feed_cubit.dart';
import 'package:locket_app/modules/friends/presentation/application/cubit/friends_cubit.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';
import 'package:locket_app/modules/profile/presentation/pages/account_edit_page.dart';
import 'package:locket_app/modules/profile/presentation/pages/notifications_page.dart';
import 'package:locket_app/modules/profile/presentation/pages/privacy_page.dart';
import 'package:locket_app/modules/profile/presentation/pages/widget_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            _ProfileHeader(
              onBack: () => Navigator.of(context).pop(),
              onEdit: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AccountEditPage()),
                );
              },
            ),
            const SizedBox(height: 22),
            const _Avatar(),
            const SizedBox(height: 14),
            const _UserIdentity(),
            const SizedBox(height: 22),
            const _ProfileStats(),
            const SizedBox(height: 28),
            const ProfileSectionLabel('SETTINGS'),
            const SizedBox(height: 10),
            const _SettingsCard(),
            const SizedBox(height: 14),
            _SignOutButton(
              onTap: () async {
                await context.read<AuthCubit>().logout();

                if (!context.mounted) {
                  return;
                }

                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const _ProfileHeader({required this.onBack, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: ProfileRoundIconButton(
              icon: Icons.chevron_left_rounded,
              onTap: onBack,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ProfileRoundIconButton(
              icon: Icons.edit_rounded,
              onTap: onEdit,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = state is Authenticated ? state.user : null;
          final photoUrl = user?.photoURL ?? '';

          return _ProfileDocumentBuilder(
            builder: (profile) {
              final displayName = _displayNameFor(user, profile);
              final initials = _initials(displayName);

              return Container(
                width: 104,
                height: 104,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black, width: 2),
                  color: AppColors.primary,
                  image: photoUrl.isEmpty
                      ? null
                      : DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.26),
                      blurRadius: 34,
                    ),
                  ],
                ),
                child: photoUrl.isEmpty
                    ? Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}

class _UserIdentity extends StatelessWidget {
  const _UserIdentity();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return _ProfileDocumentBuilder(
          builder: (profile) {
            final displayName = _displayNameFor(user, profile);
            final username = _usernameFor(user, profile);

            return Column(
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '@$username',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ProfileDocumentBuilder extends StatelessWidget {
  final Widget Function(Map<String, dynamic> profile) builder;

  const _ProfileDocumentBuilder({required this.builder});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthCubit>().state;
    final user = state is Authenticated ? state.user : null;

    if (user == null) {
      return builder(const {});
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) =>
          builder(snapshot.data?.data() ?? const {}),
    );
  }
}

String _displayNameFor(user, Map<String, dynamic> profile) {
  final firestoreName = (profile['displayName'] as String?)?.trim();
  if (firestoreName != null && firestoreName.isNotEmpty) {
    return firestoreName;
  }

  final authName = user?.displayName?.trim();
  if (authName != null && authName.isNotEmpty) {
    return authName;
  }

  return _nameFromEmail(user?.email ?? '');
}

String _usernameFor(user, Map<String, dynamic> profile) {
  final firestoreUsername = (profile['username'] as String?)?.trim();
  if (firestoreUsername != null && firestoreUsername.isNotEmpty) {
    return firestoreUsername.replaceFirst(RegExp(r'^@+'), '');
  }

  return _usernameFromEmail(user?.email ?? '');
}

String _nameFromEmail(String email) {
  if (email.isEmpty) {
    return 'You';
  }

  final rawName = email.split('@').first.replaceAll('.', ' ').trim();
  if (rawName.isEmpty) {
    return 'You';
  }

  return rawName
      .split(RegExp(r'\s+'))
      .map((word) {
        if (word.isEmpty) {
          return word;
        }
        return '${word[0].toUpperCase()}${word.substring(1)}';
      })
      .join(' ');
}

String _usernameFromEmail(String email) {
  if (email.isEmpty) {
    return 'you';
  }

  final username = email
      .split('@')
      .first
      .replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '');
  return username.isEmpty ? 'you' : username;
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  final letters = words.take(2).map((word) => word[0].toUpperCase()).join();
  return letters.isEmpty ? 'Y' : letters;
}

class _ProfileStats extends StatelessWidget {
  const _ProfileStats();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, feedState) {
        final photoCount = feedState.items.where((item) => item.isMine).length;
        final streak = _currentPhotoStreak(feedState.items);

        return BlocBuilder<FriendsCubit, FriendsState>(
          builder: (context, friendsState) {
            final friendCount = friendsState is FriendsLoaded
                ? friendsState.myFriends.length
                : 0;

            return Row(
              children: [
                Expanded(
                  child: _StatTile(value: '$photoCount', label: 'PHOTOS'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(value: '$friendCount', label: 'FRIENDS'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatTile(value: '$streak', label: 'STREAK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

int _currentPhotoStreak(List<FeedItem> items) {
  final postedDays = items
      .where((item) => item.isMine)
      .map((item) => _dateOnly(item.createdAt))
      .toSet();

  if (postedDays.isEmpty) {
    return 0;
  }

  var day = _dateOnly(DateTime.now());
  var streak = 0;

  while (postedDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }

  return streak;
}

DateTime _dateOnly(DateTime dateTime) {
  final local = dateTime.toLocal();
  return DateTime(local.year, local.month, local.day);
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;

  const _StatTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: label == 'STREAK' ? AppColors.primary : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.9,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsPage()),
              );
            },
          ),
          const ProfileSettingsDivider(),
          _SettingsRow(
            icon: Icons.lock_rounded,
            title: 'Privacy',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const PrivacyPage()));
            },
          ),
          const ProfileSettingsDivider(),
          _SettingsRow(
            icon: Icons.widgets_rounded,
            title: 'Widget',
            trailing: 'Home + Lock',
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const WidgetPage()));
            },
          ),
          const ProfileSettingsDivider(),
          const _SettingsRow(
            icon: Icons.info_rounded,
            title: 'About',
            trailing: 'v2.1.0',
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            const SizedBox(width: 12),
            ProfileSettingIcon(icon: icon),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing!,
                style: const TextStyle(
                  color: Colors.white30,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              )
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white30,
                size: 22,
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SignOutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: const Text(
          'Sign Out',
          style: TextStyle(
            color: Color(0xFFFF5A5F),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
