import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/theme.dart';
import '../../../core/widgets/widgets.dart';
import 'widgets/loan_request_card.dart';
import '../logic/loan_providers.dart';

class LoanRequestsScreen extends ConsumerStatefulWidget {
  const LoanRequestsScreen({super.key});

  @override
  ConsumerState<LoanRequestsScreen> createState() => _LoanRequestsScreenState();
}

class _LoanRequestsScreenState extends ConsumerState<LoanRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutralMid,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Incoming'),
            Tab(text: 'Outgoing'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _IncomingRequestsTab(),
          _OutgoingRequestsTab(),
        ],
      ),
    );
  }
}

class _IncomingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingAsync = ref.watch(incomingLoanRequestsProvider);

    return incomingAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
          return EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No incoming requests',
            subtitle: 'You have no pending loan requests from others.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(incomingLoanRequestsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: loans.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => LoanRequestCard(
              loan: loans[index],
              isIncoming: true,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        message: 'Could not load incoming requests',
        onRetry: () => ref.invalidate(incomingLoanRequestsProvider),
      ),
    );
  }
}

class _OutgoingRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final outgoingAsync = ref.watch(outgoingLoanRequestsProvider);

    return outgoingAsync.when(
      data: (loans) {
        if (loans.isEmpty) {
          return EmptyState(
            icon: Icons.outbox_outlined,
            title: 'No outgoing requests',
            subtitle: 'Requests you send will appear here.',
          );
        }
        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(outgoingLoanRequestsProvider),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.xl),
            itemCount: loans.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) => LoanRequestCard(
              loan: loans[index],
              isIncoming: false,
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorState(
        message: 'Could not load outgoing requests',
        onRetry: () => ref.invalidate(outgoingLoanRequestsProvider),
      ),
    );
  }
}
