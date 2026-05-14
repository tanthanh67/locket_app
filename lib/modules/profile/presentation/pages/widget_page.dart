import 'package:flutter/material.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';

class WidgetPage extends StatefulWidget {
  const WidgetPage({super.key});

  @override
  State<WidgetPage> createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  String _size = 'Small';
  Color _theme = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
          children: [
            ProfileSimpleHeader(
              title: 'Widget',
              onBack: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            Center(
              child: _PreviewCard(size: _size, color: _theme),
            ),
            const SizedBox(height: 30),
            const ProfileSectionLabel('SIZE PREVIEW'),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final size in ['Small', 'Medium', 'Large']) ...[
                  Expanded(
                    child: _SizeButton(
                      label: size,
                      selected: _size == size,
                      onTap: () => setState(() {
                        _size = size;
                      }),
                    ),
                  ),
                  if (size != 'Large') const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 28),
            const ProfileSectionLabel('SHOW ON WIDGET'),
            const SizedBox(height: 10),
            const ProfileToggleCard(
              rows: [
                ProfileToggleRow(
                  icon: Icons.text_fields_rounded,
                  title: 'Show captions',
                ),
                ProfileToggleRow(
                  icon: Icons.schedule_rounded,
                  title: 'Show timestamp',
                ),
                ProfileToggleRow(
                  icon: Icons.shuffle_rounded,
                  title: 'Auto-rotate feed',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const ProfileSectionLabel('THEME'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                children: [
                  for (final color in const [
                    AppColors.primary,
                    Color(0xFFFF7B68),
                    Color(0xFF4D9CAE),
                    Colors.white,
                    Colors.black,
                  ]) ...[
                    _ThemeSwatch(
                      color: color,
                      selected: _theme == color,
                      onTap: () => setState(() {
                        _theme = color;
                      }),
                    ),
                    const SizedBox(width: 10),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String size;
  final Color color;

  const _PreviewCard({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    final dimensions = switch (size) {
      'Medium' => const Size(132, 132),
      'Large' => const Size(156, 156),
      _ => const Size(112, 112),
    };
    final textColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return Container(
      width: dimensions.width,
      height: dimensions.height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.32),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '@private',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '2m',
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            'saturday\nafternoon',
            style: TextStyle(
              color: textColor,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SizeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF24200D) : AppColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.primary : Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeSwatch({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color.computeLuminance() > 0.5
        ? Colors.black
        : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: selected
            ? Icon(Icons.check_rounded, color: iconColor, size: 22)
            : null,
      ),
    );
  }
}
