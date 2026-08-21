import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/app_spinner.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../auth/presentation/providers/logout_controller.dart';
import '../../../wallet/presentation/providers/wallet_balance_provider.dart';
import '../providers/profile_controller.dart';
import '../providers/upload_photo_controller.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;
    if (!mounted) return;

    await ref.read(uploadPhotoControllerProvider.notifier).upload(picked.path);

    if (!mounted) return;
    final state = ref.read(uploadPhotoControllerProvider);
    if (state.hasError) {
      context.showSnack('Could not update your photo. Please try again.', isError: true);
    } else {
      context.showSnack('Profile photo updated');
    }
  }

  Future<void> _confirmLogout() async {
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
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final uploadState = ref.watch(uploadPhotoControllerProvider);
    // hasTransactionPin lives on the wallet record on the backend, not the
    // user — sourced from here rather than AuthUser.hasTransactionPin.
    final hasPin = ref.watch(walletBalanceProvider).value?.hasPin ?? false;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(profileControllerProvider.notifier).refresh(),
        child: profileAsync.when(
          loading: () => const AppSpinner(),
          error: (error, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  message: 'Could not load your profile. Pull down to try again.',
                  actionLabel: 'Retry',
                  onAction: () => ref.read(profileControllerProvider.notifier).refresh(),
                ),
              ),
            ],
          ),
          data: (user) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: AppColors.primary,
                          backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                          child: user.avatarUrl == null
                              ? Text(
                                  user.name.initials,
                                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600),
                                )
                              : null,
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: uploadState.isLoading ? null : _pickPhoto,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                              child: uploadState.isLoading
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(user.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        _StatusChip(label: 'BVN', verified: user.isBvnVerified),
                        _StatusChip(label: 'Transaction PIN', verified: hasPin),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                label: 'Edit Profile',
                onTap: () => context.push(AppRoutes.editProfile),
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Change Password',
                onTap: () => context.push(AppRoutes.changePassword),
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.pin_outlined,
                label: hasPin ? 'Change Transaction PIN' : 'Set Transaction PIN',
                onTap: () => context.push(AppRoutes.setPin),
              ),
              if (!user.isBvnVerified) ...[
                const Divider(height: 1),
                ProfileMenuItem(
                  icon: Icons.verified_user_outlined,
                  label: 'Verify BVN',
                  onTap: () => context.push(AppRoutes.verifyBvn),
                ),
              ],
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => context.push(AppRoutes.settings),
              ),
              const Divider(height: 1),
              ProfileMenuItem(
                icon: Icons.logout_rounded,
                label: 'Log Out',
                iconColor: AppColors.error,
                trailing: const SizedBox.shrink(),
                onTap: _confirmLogout,
              ),
              const Divider(height: 1),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.verified});

  final String label;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final color = verified ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.check_circle_rounded : Icons.warning_rounded, size: 13, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
