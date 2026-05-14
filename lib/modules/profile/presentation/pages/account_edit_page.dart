import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/auth/presentation/application/cubit/auth_cubit.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';

class AccountEditPage extends StatefulWidget {
  const AccountEditPage({super.key});

  @override
  State<AccountEditPage> createState() => _AccountEditPageState();
}

class _AccountEditPageState extends State<AccountEditPage> {
  final _displayNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  String? _loadedUid;
  String _initialDisplayName = '';
  String _initialUsername = '';

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated && state.user.uid != _loadedUid) {
          _loadProfile(state.user.uid, state.user.email ?? '');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final user = state is Authenticated ? state.user : null;
              final email = user?.email ?? '';
              final displayName = user?.displayName?.trim() ?? '';
              final fallbackName = displayName.isEmpty
                  ? _nameFromEmail(email)
                  : displayName;
              final currentName = _displayNameController.text.trim().isEmpty
                  ? fallbackName
                  : _displayNameController.text.trim();
              final initials = _initials(currentName);

              if (user != null && _loadedUid != user.uid && !_isSaving) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    _loadProfile(user.uid, email);
                  }
                });
              }

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                children: [
                  _AccountHeader(
                    isSaving: _isSaving,
                    onBack: () => Navigator.of(context).pop(),
                    onSave: _hasChanges ? _saveAccount : null,
                  ),
                  const SizedBox(height: 28),
                  _EditableAvatar(initials: initials),
                  const SizedBox(height: 14),
                  Text(
                    currentName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '@${_usernameController.text.trim().isEmpty ? _usernameFromEmail(email) : _usernameController.text.trim()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 34),
                  const ProfileSectionLabel('PROFILE'),
                  const SizedBox(height: 10),
                  _isLoadingProfile
                      ? const _LoadingCard()
                      : _AccountFormCard(
                          displayNameController: _displayNameController,
                          usernameController: _usernameController,
                          emailController: _emailController,
                          onChanged: () => setState(() {}),
                        ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool get _hasChanges {
    return _displayNameController.text.trim() != _initialDisplayName ||
        _usernameController.text.trim() != _initialUsername;
  }

  Future<void> _loadProfile(String uid, String email) async {
    setState(() {
      _isLoadingProfile = true;
      _loadedUid = uid;
    });

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    final data = doc.data() ?? const <String, dynamic>{};
    final displayName =
        (data['displayName'] as String?)?.trim().isNotEmpty == true
        ? (data['displayName'] as String).trim()
        : _nameFromEmail(email);
    final username = (data['username'] as String?)?.trim().isNotEmpty == true
        ? (data['username'] as String).trim()
        : _usernameFromEmail(email);

    if (!mounted) {
      return;
    }

    setState(() {
      _displayNameController.text = displayName;
      _usernameController.text = username;
      _emailController.text = email;
      _initialDisplayName = displayName;
      _initialUsername = username;
      _isLoadingProfile = false;
    });
  }

  Future<void> _saveAccount() async {
    final displayName = _displayNameController.text.trim();
    final username = _usernameController.text.trim().replaceFirst(
      RegExp(r'^@+'),
      '',
    );

    if (displayName.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name and username are required.'),
        ),
      );
      return;
    }

    if (_usernameController.text.trim() != username) {
      _usernameController.text = username;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await context.read<AuthCubit>().updateAccount(
        displayName: displayName,
        username: username,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _initialDisplayName = displayName;
      _initialUsername = username;
      _isSaving = false;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account updated.')));
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
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  String _usernameFromEmail(String email) {
    if (email.isEmpty) {
      return 'you';
    }
    return email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9._]'), '');
  }

  String _initials(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);
    final letters = words.take(2).map((word) => word[0].toUpperCase()).join();
    return letters.isEmpty ? 'Y' : letters;
  }
}

class _AccountHeader extends StatelessWidget {
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback? onSave;

  const _AccountHeader({
    required this.isSaving,
    required this.onBack,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF24200D),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Align(
              alignment: Alignment.centerLeft,
              child: ProfileRoundIconButton(
                icon: Icons.chevron_left_rounded,
                onTap: onBack,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Account',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: onSave == null ? 0.35 : 1,
            duration: const Duration(milliseconds: 160),
            child: InkWell(
              onTap: isSaving ? null : onSave,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: 62,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditableAvatar extends StatelessWidget {
  final String initials;

  const _EditableAvatar({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 116,
            height: 116,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.26),
                  blurRadius: 38,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 8,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF222226),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 3),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountFormCard extends StatelessWidget {
  final TextEditingController displayNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final VoidCallback onChanged;

  const _AccountFormCard({
    required this.displayNameController,
    required this.usernameController,
    required this.emailController,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _AccountFieldRow(
            icon: Icons.person_outline_rounded,
            label: 'Display name',
            controller: displayNameController,
            hintText: 'Your name',
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
          ),
          const ProfileSettingsDivider(),
          _AccountFieldRow(
            icon: Icons.alternate_email_rounded,
            label: 'Username',
            controller: usernameController,
            hintText: 'username',
            prefixText: '@',
            textInputAction: TextInputAction.next,
            onChanged: onChanged,
          ),
          const ProfileSettingsDivider(),
          _AccountFieldRow(
            icon: Icons.email_rounded,
            label: 'Email',
            controller: emailController,
            hintText: 'email@example.com',
            readOnly: true,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AccountFieldRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? prefixText;
  final bool readOnly;
  final TextInputAction? textInputAction;
  final VoidCallback onChanged;

  const _AccountFieldRow({
    required this.icon,
    required this.label,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.prefixText,
    this.readOnly = false,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 92),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 12),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: ProfileSettingIcon(icon: icon),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (readOnly)
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white24,
                          size: 16,
                        )
                      else
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white24,
                          size: 20,
                        ),
                    ],
                  ),
                  TextField(
                    controller: controller,
                    readOnly: readOnly,
                    textInputAction: textInputAction,
                    onChanged: (_) => onChanged(),
                    style: TextStyle(
                      color: readOnly ? Colors.white38 : Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    cursorColor: AppColors.primary,
                    decoration: InputDecoration(
                      prefixText: prefixText,
                      prefixStyle: const TextStyle(
                        color: Colors.white38,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      hintText: hintText,
                      hintStyle: const TextStyle(color: Colors.white24),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(top: 8),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
