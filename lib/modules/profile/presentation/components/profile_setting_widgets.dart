import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:locket_app/core/constants/app_colors.dart';

class ProfileSimpleHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ProfileSimpleHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
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
        ],
      ),
    );
  }
}

class ProfileRoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const ProfileRoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFF202023),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

class ProfileSectionLabel extends StatelessWidget {
  final String text;

  const ProfileSectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white30,
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.6,
      ),
    );
  }
}

class ProfileSettingIcon extends StatelessWidget {
  final IconData icon;

  const ProfileSettingIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF3B3415),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: AppColors.primary, size: 16),
    );
  }
}

class ProfileSettingsDivider extends StatelessWidget {
  const ProfileSettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        color: Colors.white.withValues(alpha: 0.06),
        height: 1,
        thickness: 1,
      ),
    );
  }
}

class ProfileToggleCard extends StatelessWidget {
  final List<Widget> rows;

  const ProfileToggleCard({super.key, required this.rows});

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
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i != rows.length - 1) const ProfileSettingsDivider(),
          ],
        ],
      ),
    );
  }
}

class ProfileToggleRow extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final bool showSwitch;
  final bool initialValue;
  final bool? value;
  final ValueChanged<bool>? onChanged;

  const ProfileToggleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.showSwitch = true,
    this.initialValue = true,
    this.value,
    this.onChanged,
  });

  @override
  State<ProfileToggleRow> createState() => _ProfileToggleRowState();
}

class _ProfileToggleRowState extends State<ProfileToggleRow> {
  late bool _enabled = widget.initialValue;

  bool get _value => widget.value ?? _enabled;

  void _setValue(bool value) {
    if (widget.value == null) {
      setState(() {
        _enabled = value;
      });
    }

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.showSwitch ? () => _setValue(!_value) : null,
      child: SizedBox(
        height: widget.subtitle == null ? 56 : 70,
        child: Row(
          children: [
            const SizedBox(width: 12),
            ProfileSettingIcon(icon: widget.icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (widget.subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(
                      widget.subtitle!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (widget.trailing != null)
              Text(
                widget.trailing!,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (widget.showSwitch) const SizedBox(width: 10),
            if (widget.showSwitch)
              Switch.adaptive(
                value: _value,
                activeThumbColor: Colors.black,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFF2C2C30),
                onChanged: _setValue,
              ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }
}

class ProfileStoredToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String settingPath;
  final bool defaultValue;

  const ProfileStoredToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.settingPath,
    this.subtitle,
    this.defaultValue = true,
  });

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return ProfileToggleRow(
        icon: icon,
        title: title,
        subtitle: subtitle,
        initialValue: defaultValue,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final value = _boolAtPath(data, settingPath) ?? defaultValue;

        return ProfileToggleRow(
          icon: icon,
          title: title,
          subtitle: subtitle,
          value: value,
          onChanged: (nextValue) async {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({
                  ..._nestedMapForPath(settingPath, nextValue),
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));
          },
        );
      },
    );
  }
}

bool? _boolAtPath(Map<String, dynamic> data, String path) {
  Object? current = data;

  for (final segment in path.split('.')) {
    if (current is! Map<String, dynamic>) {
      return null;
    }
    current = current[segment];
  }

  return current is bool ? current : null;
}

Map<String, dynamic> _nestedMapForPath(String path, bool value) {
  final segments = path.split('.');
  Map<String, dynamic> current = {segments.last: value};

  for (final segment in segments.reversed.skip(1)) {
    current = {segment: current};
  }

  return current;
}
