import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/api/api_client.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) => const AuthRepository());

// Auth state
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isBootstrapping = true,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isBootstrapping;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isBootstrapping,
    bool clearUser = false,
    bool clearError = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : (error ?? this.error),
        isBootstrapping: isBootstrapping ?? this.isBootstrapping,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _bootstrap();
  }

  final AuthRepository _repo;

  Future<void> _bootstrap() async {
    try {
      final (token, user) = await _repo.getCachedAuth();
      if (token != null && user != null) {
        state = AuthState(user: user, isBootstrapping: false);
        return;
      }
    } catch (_) {}
    state = const AuthState(isBootstrapping: false);
  }

  Future<void> login({String? email, String? phone, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repo.login(email: email, phone: phone, password: password);
      state = AuthState(user: tokens.user, isBootstrapping: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseError(e));
    }
  }

  Future<void> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tokens = await _repo.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      state = AuthState(user: tokens.user, isBootstrapping: false);
    } on Exception catch (e) {
      state = state.copyWith(isLoading: false, error: ApiClient.parseError(e));
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AuthState(isBootstrapping: false);
  }

  Future<void> refreshUser() async {
    try {
      final user = await _repo.getMe();
      state = state.copyWith(user: user);
    } catch (_) {}
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
