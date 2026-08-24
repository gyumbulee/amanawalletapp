import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/buttons/primary_button.dart';
import '../../../../shared/widgets/inputs/app_text_field.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../../../core/errors/failure.dart';
import '../providers/create_ticket_controller.dart';

/// Reached two ways: generally from Settings (transactionReference is
/// null), or via "Need help with this transaction?" on the transaction
/// detail screen (transactionReference pre-fills a locked reference chip
/// and a starter subject, both still editable except the reference itself).
class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key, this.transactionReference});

  final String? transactionReference;

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _subjectController = TextEditingController(
    text: widget.transactionReference != null ? 'Help with transaction ${widget.transactionReference}' : '',
  );
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    await ref.read(createTicketControllerProvider.notifier).submit(
          subject: _subjectController.text.trim(),
          message: _messageController.text.trim(),
          transactionReference: widget.transactionReference,
        );

    if (!mounted) return;
    final state = ref.read(createTicketControllerProvider);
    state.whenOrNull(
      data: (ticket) {
        if (ticket != null) {
          context.showSnack('Support ticket created.');
          context.pushReplacement(AppRoutes.supportTicketDetailPath(ticket.id));
        }
      },
      error: (error, _) {
        final failure = error is Failure ? error : null;
        context.showSnack(failure?.message ?? 'Could not create your ticket. Please try again.', isError: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(createTicketControllerProvider).isLoading;

    return ResponsiveScaffold(
      appBar: AppBar(title: const Text('New Support Ticket')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (widget.transactionReference != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Regarding transaction ${widget.transactionReference}',
                        style: const TextStyle(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            AppTextField(
              label: 'Subject',
              controller: _subjectController,
              textInputAction: TextInputAction.next,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter a subject' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'How can we help?',
              hintText: 'Describe your issue in detail...',
              controller: _messageController,
              maxLines: 6,
              minLines: 6,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Please describe your issue' : null,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Submit Ticket',
              isLoading: isSubmitting,
              onPressed: _submit,
            ),
          ],
          ),
        ),
      ),
    );
  }
}
