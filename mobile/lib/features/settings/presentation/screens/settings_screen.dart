import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/logout_controller.dart';
import '../theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(logoutControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 4),
          const Text(
            'Choose how Amana Wallet looks on this device.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          _ThemeOption(
            label: 'System Default',
            icon: Icons.brightness_auto_rounded,
            selected: themeMode == ThemeMode.system,
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system),
          ),
          _ThemeOption(
            label: 'Light',
            icon: Icons.light_mode_outlined,
            selected: themeMode == ThemeMode.light,
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light),
          ),
          _ThemeOption(
            label: 'Dark',
            icon: Icons.dark_mode_outlined,
            selected: themeMode == ThemeMode.dark,
            onTap: () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark),
          ),
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.logout_rounded, color: AppColors.error),
            title: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w500)),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppColors.accent : AppColors.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? AppColors.accent : Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.accent, size: 20),
          ],
        ),
      ),
    );
  }
}
