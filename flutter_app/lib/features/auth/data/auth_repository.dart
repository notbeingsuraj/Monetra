import '../../../services/api/api_client.dart';
import '../../../services/storage/storage_service.dart';
import '../../../core/models/user_model.dart';
import 'user_model.dart' as auth_models;

class AuthRepository {
  const AuthRepository();

  Future<auth_models.AuthTokens> login({String? email, String? phone, required String password}) async {
    final tokens = await ApiClient.instance.post<auth_models.AuthTokens>(
      '/auth/login',
      data: {if (email != null) 'email': email, if (phone != null) 'phone': phone, 'password': password},
      fromJson: auth_models.AuthTokens.fromJson,
    );
    await StorageService.instance.setToken(tokens.token);
    if (tokens.refreshToken != null) {
      await StorageService.instance.setRefreshToken(tokens.refreshToken!);
    }
    await StorageService.instance.setUserJson(tokens.user.toJsonString());
    return tokens;
  }

  Future<auth_models.AuthTokens> register({
    required String name,
    String? email,
    String? phone,
    required String password,
  }) async {
    final tokens = await ApiClient.instance.post<auth_models.AuthTokens>(
      '/auth/register',
      data: {
        'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'password': password,
      },
      fromJson: auth_models.AuthTokens.fromJson,
    );
    await StorageService.instance.setToken(tokens.token);
    if (tokens.refreshToken != null) {
      await StorageService.instance.setRefreshToken(tokens.refreshToken!);
    }
    await StorageService.instance.setUserJson(tokens.user.toJsonString());
    return tokens;
  }

  Future<UserModel> getMe() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/auth/me');
    return UserModel.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() => StorageService.instance.clearAll();

  Future<(String?, UserModel?)> getCachedAuth() async {
    final token = await StorageService.instance.getToken();
    final userJson = await StorageService.instance.getUserJson();
    if (token != null && userJson != null) {
      return (token, auth_models.UserModelExtensions.fromJsonString(userJson));
    }
    return (null, null);
  }
}
