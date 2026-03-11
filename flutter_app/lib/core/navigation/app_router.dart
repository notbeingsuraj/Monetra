import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/logic/auth_provider.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/lending/presentation/add_loan_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../constants/app_routes.dart';
import 'app_shell.dart';

/// Bridges Riverpod [authProvider] to GoRouter's [refreshListenable].
/// GoRouter calls [redirect] when this notifies — no new GoRouter instance created.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    // Re-evaluate redirect whenever auth state changes
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
    _authState = ref.read(authProvider);
    ref.listen<AuthState>(authProvider, (_, next) => _authState = next);
  }

  late AuthState _authState;

  String? redirect(BuildContext context, GoRouterState state) {
    final isBootstrapping = _authState.isBootstrapping;
    if (isBootstrapping) return null;

    final isAuthenticated = _authState.isAuthenticated;
    final isAuthRoute = state.matchedLocation == AppRoutes.login ||
        state.matchedLocation == AppRoutes.register;

    if (!isAuthenticated && !isAuthRoute) return AppRoutes.login;
    if (isAuthenticated && isAuthRoute) return AppRoutes.dashboard;
    return null;
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _RouterNotifier(ref);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Auth routes — no shell, no bottom nav
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (_, __) => const RegisterScreen(),
      ),
      // Shell routes — wrapped in bottom nav
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            name: 'dashboard',
            pageBuilder: (_, __) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            name: 'transactions',
            pageBuilder: (_, __) => const NoTransitionPage(child: TransactionsScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            name: 'profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
          ),
        ],
      ),
      // Modal / push routes
      GoRoute(
        path: AppRoutes.lend,
        name: 'lend',
        builder: (_, __) => const AddLoanScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});
