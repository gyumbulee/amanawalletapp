import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/extensions/string_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../providers/profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _initFromUser(String name, String phone) {
    if (_initialized) return;
    final parts = name.trim().split(RegExp(r'\s+'));
    _firstNameController = TextEditingController(text: parts.isNotEmpty ? parts.first : '');
    _lastNameController = TextEditingController(text: parts.length > 1 ? parts.sublist(1).join(' ') : '');
    _phoneController = TextEditingController(text: phone);
    _initialized = true;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await ref.read(profileControllerProvider.notifier).updateProfile(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: _phoneController.text.trim(),
        );
    if (!mounted) return;
    if (success) {
      context.showSnack('Profile updated');
      context.pop();
    } else {
      context.showSnack('Could not update your profile. Please try again.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileControllerProvider);
    final isSubmitting = profileAsync.isLoading;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.maybeWhen(
        data: (user) {
          _initFromUser(user.name, user.phone);
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: 'First Name',
                    controller: _firstNameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        (value == null || value.trim().length < 2) ? 'Enter your first name' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (value) =>
                        (value == null || value.trim().length < 2) ? 'Enter your last name' : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Phone Number',
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_iphone_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Phone number is required';
                      if (!value.isValidNigerianPhone) return 'Enter a valid Nigerian phone number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Save Changes',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}
