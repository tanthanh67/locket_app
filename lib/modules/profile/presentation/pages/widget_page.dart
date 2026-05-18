import 'package:flutter/material.dart';
import 'package:locket_app/core/constants/app_colors.dart';
import 'package:locket_app/core/services/widget_sync_service.dart';
import 'package:locket_app/modules/profile/presentation/components/profile_setting_widgets.dart';

class WidgetPage extends StatefulWidget {
  const WidgetPage({super.key});

  @override
  State<WidgetPage> createState() => _WidgetPageState();
}

class _WidgetPageState extends State<WidgetPage> {
  final WidgetSyncService _widgetSyncService = WidgetSyncService();
  String _size = 'Small';
  Color _theme = AppColors.primary;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isCreatingWidget = false;

  @override
  void initState() {
    super.initState();
    _loadWidgetSettings();
  }

  Future<void> _loadWidgetSettings() async {
    try {
      final size = await _widgetSyncService.getSize();
      final themeColorValue = await _widgetSyncService.getThemeColor(
        fallback: AppColors.primary,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _size = _normalizeSize(size);
        _theme = Color(themeColorValue);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
      _showMessage('Could not load widget settings');
    }
  }

  Future<void> _selectSize(String size) async {
    if (_size == size || _isSaving) {
      return;
    }

    setState(() {
      _size = size;
    });
    await _saveSettings();
  }

  Future<void> _selectTheme(Color color) async {
    if (_theme == color || _isSaving) {
      return;
    }

    setState(() {
      _theme = color;
    });
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      await _widgetSyncService.syncSettings(size: _size, themeColor: _theme);
      if (mounted) {
        _showMessage('Widget updated');
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Could not update widget');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _createWidget() async {
    setState(() {
      _isCreatingWidget = true;
    });

    try {
      await _widgetSyncService.syncSettings(size: _size, themeColor: _theme);
      await _widgetSyncService.syncPreviewData();
      final isSupported = await _widgetSyncService.isCreateWidgetSupported();

      if (!mounted) {
        return;
      }

      if (!isSupported) {
        _showMessage('Your launcher does not support quick widget creation');
        return;
      }

      await _widgetSyncService.createWidget();
    } catch (_) {
      if (mounted) {
        _showMessage('Could not create widget');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingWidget = false;
        });
      }
    }
  }

  String _normalizeSize(String size) {
    return switch (size) {
      'Medium' || 'Large' => size,
      _ => 'Small',
    };
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                child: _isLoading
                    ? const _PreviewLoadingCard()
                    : _PreviewCard(
                        key: ValueKey('$_size-${_theme.toARGB32()}'),
                        size: _size,
                        color: _theme,
                      ),
              ),
            ),
            const SizedBox(height: 22),
            _CreateWidgetButton(
              isLoading: _isCreatingWidget,
              onTap: _createWidget,
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
                      isSaving: _isSaving,
                      onTap: () => _selectSize(size),
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
                      onTap: () => _selectTheme(color),
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

class _CreateWidgetButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _CreateWidgetButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.22),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            else
              const Icon(
                Icons.add_to_home_screen_rounded,
                color: Colors.black,
                size: 21,
              ),
            const SizedBox(width: 9),
            const Text(
              'Create Widget',
              style: TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewLoadingCard extends StatelessWidget {
  const _PreviewLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String size;
  final Color color;

  const _PreviewCard({super.key, required this.size, required this.color});

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
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(11),
              ),
              child: const Text(
                '2m',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
              ),
              child: const Text(
                'P',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          Positioned(
            left: 48,
            right: 0,
            bottom: 1,
            child: Text(
              'saturday\nafternoon',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
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
  final bool isSaving;
  final VoidCallback onTap;

  const _SizeButton({
    required this.label,
    required this.selected,
    required this.isSaving,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSaving && !selected ? 0.55 : 1,
      child: InkWell(
        onTap: isSaving ? null : onTap,
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
