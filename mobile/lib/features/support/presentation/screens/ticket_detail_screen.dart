import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/failure.dart';
import '../../../../shared/extensions/context_extensions.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../../../../theme/app_colors.dart';
import '../../domain/entities/support_ticket.dart';
import '../providers/support_ticket_detail_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/ticket_status_badge.dart';

class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendReply() async {
    final message = _replyController.text.trim();
    if (message.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await ref.read(supportTicketDetailProvider(widget.ticketId).notifier).sendReply(message);
      _replyController.clear();
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      final failure = e is Failure ? e : null;
      context.showSnack(failure?.message ?? 'Could not send your reply. Please try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(supportTicketDetailProvider(widget.ticketId));

    return ResponsiveScaffold(
      padding: EdgeInsets.zero,
      appBar: AppBar(
        title: ticketAsync.value != null
            ? Text(ticketAsync.value!.subject, maxLines: 1, overflow: TextOverflow.ellipsis)
            : const Text('Support Ticket'),
        actions: [
          if (ticketAsync.value != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: TicketStatusBadge(status: ticketAsync.value!.status)),
            ),
        ],
      ),
      body: ticketAsync.when(
        loading: () => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5,
          itemBuilder: (context, i) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: SkeletonLoader(height: 48),
          ),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Could not load this ticket.'),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => ref.read(supportTicketDetailProvider(widget.ticketId).notifier).refresh(),
                  child: const Text('Try again'),
                ),
              ],
            ),
          ),
        ),
        data: (ticket) {
          _scrollToBottom();
          final isClosed = ticket.status == SupportTicketStatus.closed;

          return Column(
            children: [
              if (ticket.transactionReference != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.accent.withValues(alpha: 0.08),
                  child: Text(
                    'Re: transaction ${ticket.transactionReference}',
                    style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w600),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: ticket.messages.length,
                  itemBuilder: (context, index) => MessageBubble(message: ticket.messages[index]),
                ),
              ),
              if (isClosed)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    'This ticket is closed. Send a message to reopen it.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        minLines: 1,
                        maxLines: 4,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendReply(),
                        decoration: const InputDecoration(
                          hintText: 'Type your reply...',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _isSending
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          )
                        : IconButton.filled(
                            onPressed: _sendReply,
                            icon: const Icon(Icons.send_rounded),
                          ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
