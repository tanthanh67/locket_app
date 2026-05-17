import 'package:flutter/material.dart';
import 'package:locket_app/modules/feed/presentation/components/circle_button.dart';

class FeedTopBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final VoidCallback? onChatTap;
  final String? centerLabel;
  final IconData centerIcon;
  final List<String> filterOptions;
  final String selectedFilter;
  final VoidCallback? onCenterTap;
  final ValueChanged<String>? onFilterChanged;

  const FeedTopBar({
    super.key,
    this.onProfileTap,
    this.onChatTap,
    this.centerLabel,
    this.centerIcon = Icons.group_rounded,
    this.filterOptions = const ['All friends'],
    this.selectedFilter = 'All friends',
    this.onCenterTap,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final label = centerLabel ?? selectedFilter;
    final canOpenFilter = centerLabel == null && onFilterChanged != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleButton(icon: Icons.person_outline_rounded, onTap: onProfileTap),
          _CenterPill(
            label: label,
            icon: centerIcon,
            options: filterOptions,
            canOpen: canOpenFilter,
            onTap: onCenterTap,
            onChanged: onFilterChanged,
          ),
          CircleButton(
            icon: Icons.chat_bubble_outline_rounded,
            onTap: onChatTap,
          ),
        ],
      ),
    );
  }
}

class _CenterPill extends StatefulWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final bool canOpen;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const _CenterPill({
    required this.label,
    required this.icon,
    required this.options,
    required this.canOpen,
    this.onTap,
    this.onChanged,
  });

  @override
  State<_CenterPill> createState() => _CenterPillState();
}

class _CenterPillState extends State<_CenterPill> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.canOpen ? _openMenu : widget.onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          key: _anchorKey,
          width: 178,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF2F2F2F),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 24),
              const SizedBox(width: 10),
              Flexible(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeOutCubic,
                  child: Text(
                    widget.label,
                    key: ValueKey(widget.label),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              if (widget.canOpen) ...[
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isMenuOpen ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.white70,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openMenu() async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final buttonBox =
        _anchorKey.currentContext!.findRenderObject() as RenderBox;
    final buttonPosition = buttonBox.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );
    final buttonRect = buttonPosition & buttonBox.size;

    setState(() {
      _isMenuOpen = true;
    });

    final selected = await showMenu<String>(
      context: context,
      color: const Color(0xFF2A2A28),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A3A38), width: 0.6),
      ),
      position: RelativeRect.fromRect(
        Rect.fromLTWH(
          buttonRect.left,
          buttonRect.bottom + 8,
          buttonRect.width,
          buttonRect.height,
        ),
        Offset.zero & overlay.size,
      ),
      constraints: const BoxConstraints(minWidth: 220),
      items: widget.options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 48,
              child: _buildMenuRow(option),
            ),
          )
          .toList(),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isMenuOpen = false;
    });

    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  Widget _buildMenuRow(String option) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 14,
          backgroundColor: Color(0xFF3A3A38),
          child: Icon(Icons.group, size: 16, color: Colors.white70),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            option,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Colors.white30,
        ),
      ],
    );
  }
}
