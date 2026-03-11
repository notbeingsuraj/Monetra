import '../../../services/api/api_client.dart';
import '../../../services/storage/storage_service.dart';
import 'user_model.dart';

class AuthRepository {
  const AuthRepository();

  Future<AuthTokens> login({String? email, String? phone, required String password}) async {
    final tokens = await ApiClient.instance.post<AuthTokens>(
      '/auth/login',
      data: {if (email != null) 'email': email, if (phone != null) 'phone': phone, 'password': password},
      fromJson: AuthTokens.fromJson,
    );
    await StorageService.instance.setToken(tokens.token);
    await StorageService.instance.setUserJson(tokens.user.toJsonString());
    return tokens;
  }

  Future<AuthTokens> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    final tokens = await ApiClient.instance.post<AuthTokens>(
      '/auth/register',
      data: {
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
      },
      fromJson: AuthTokens.fromJson,
    );
    await StorageService.instance.setToken(tokens.token);
    await StorageService.instance.setUserJson(tokens.user.toJsonString());
    return tokens;
  }

  Future<User> getMe() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/auth/me');
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() => StorageService.instance.clearAll();

  Future<(String?, User?)> getCachedAuth() async {
    final token = await StorageService.instance.getToken();
    final userJson = await StorageService.instance.getUserJson();
    if (token != null && userJson != null) {
      return (token, User.fromJsonString(userJson));
    }
    return (null, null);
  }
}
