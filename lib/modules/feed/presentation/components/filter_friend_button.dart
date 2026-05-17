import 'package:flutter/material.dart';

class FilterFriendButton extends StatefulWidget {
  final List<String> options;
  final ValueChanged<String>? onChanged;
  final String selectedLabel;

  const FilterFriendButton({
    super.key,
    this.options = const ['All friends'],
    this.onChanged,
    this.selectedLabel = 'All friends',
  });

  @override
  State<FilterFriendButton> createState() => _FilterFriendButtonState();
}

class _FilterFriendButtonState extends State<FilterFriendButton> {
  final GlobalKey _anchorKey = GlobalKey();
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _openMenu,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          key: _anchorKey,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1C),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF2E2E2C), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.selectedLabel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 6),
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
            ),
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
