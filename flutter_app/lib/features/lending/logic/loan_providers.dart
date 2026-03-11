import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/loan_repository.dart';
import '../data/loan_models.dart';

final loanRepositoryProvider = Provider<LoanRepository>((ref) => const LoanRepository());

// Loans list — keyed by status filter
final loansProvider = FutureProvider.family<List<Loan>, String?>(
  (ref, status) => ref.read(loanRepositoryProvider).getLoans(status: status),
);

// Dashboard summary
final loanSummaryProvider = FutureProvider<LoanSummary>(
  (ref) => ref.read(loanRepositoryProvider).getSummary(),
);

// Active loans (pending, limit 5) for dashboard
final activeLoansProvider = FutureProvider<List<Loan>>(
  (ref) => ref.read(loanRepositoryProvider).getLoans(status: 'pending', limit: 5),
);

// Trust score
final trustScoreProvider = FutureProvider<TrustScoreData>(
  (ref) => ref.read(loanRepositoryProvider).getTrustScore(),
);

// Loan detail
final loanDetailProvider =
    FutureProvider.family<({Loan loan, List<Repayment> repayments}), String>(
  (ref, id) => ref.read(loanRepositoryProvider).getLoanDetail(id),
);

// Create loan notifier
class CreateLoanNotifier extends StateNotifier<AsyncValue<void>> {
  CreateLoanNotifier(this._repo) : super(const AsyncValue.data(null));

  final LoanRepository _repo;

  Future<bool> createLoan(CreateLoanPayload payload) async {
    state = const AsyncValue.loading();
    try {
      await _repo.createLoan(payload);
      state = const AsyncValue.data(null);
      return true;
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  void reset() => state = const AsyncValue.data(null);
}

final createLoanProvider =
    StateNotifierProvider<CreateLoanNotifier, AsyncValue<void>>(
  (ref) => CreateLoanNotifier(ref.read(loanRepositoryProvider)),
);
