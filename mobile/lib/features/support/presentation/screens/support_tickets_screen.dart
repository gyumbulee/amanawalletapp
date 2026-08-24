import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routing/app_router.dart';
import '../../../../shared/widgets/empty_states/empty_state.dart';
import '../../../../shared/widgets/loaders/skeleton_loader.dart';
import '../../../../shared/widgets/responsive_scaffold.dart';
import '../providers/support_ticket_list_provider.dart';
import '../widgets/ticket_list_tile.dart';

class SupportTicketsScreen extends ConsumerStatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  ConsumerState<SupportTicketsScreen> createState() => _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(supportTicketListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(supportTicketListProvider);

    return ResponsiveScaffold(
      appBar: AppBar(
        title: const Text('Support'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New ticket',
            onPressed: () => context.push(AppRoutes.newSupportTicket),
          ),
        ],
      ),
      body: listState.when(
        loading: () => ListView.builder(
          itemCount: 6,
          itemBuilder: (context, i) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: SkeletonListTile(),
          ),
        ),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          message: 'Could not load your support tickets.',
          actionLabel: 'Try again',
          onAction: () => ref.read(supportTicketListProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.tickets.isEmpty) {
            return EmptyState(
              icon: Icons.support_agent_outlined,
              message: "You haven't raised any support tickets yet.",
              actionLabel: 'New ticket',
              onAction: () => context.push(AppRoutes.newSupportTicket),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(supportTicketListProvider.notifier).refresh(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.tickets.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= state.tickets.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                }
                final ticket = state.tickets[index];
                return TicketListTile(
                  ticket: ticket,
                  onTap: () => context.push(AppRoutes.supportTicketDetailPath(ticket.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
