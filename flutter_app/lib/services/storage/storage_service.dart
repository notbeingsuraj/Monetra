import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/app_constants.dart';

class StorageService {
  StorageService._();

  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Token
  Future<String?> getToken() => _storage.read(key: AppConstants.tokenKey);

  Future<void> setToken(String token) =>
      _storage.write(key: AppConstants.tokenKey, value: token);

  Future<void> deleteToken() => _storage.delete(key: AppConstants.tokenKey);

  // User JSON
  Future<String?> getUserJson() => _storage.read(key: AppConstants.userKey);

  Future<void> setUserJson(String json) =>
      _storage.write(key: AppConstants.userKey, value: json);

  Future<void> deleteUserJson() => _storage.delete(key: AppConstants.userKey);

  // Clear everything on logout
  Future<void> clearAll() => _storage.deleteAll();
}
