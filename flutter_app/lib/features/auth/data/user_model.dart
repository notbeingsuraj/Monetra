import 'dart:convert';
import '../../../core/models/user_model.dart';

class AuthTokens {
  const AuthTokens({required this.token, required this.user, this.refreshToken});

  final String token;
  final String? refreshToken;
  final UserModel user;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        token: json['token'] as String,
        refreshToken: json['refreshToken'] as String?,
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

extension UserModelExtensions on UserModel {
  String toJsonString() => jsonEncode(toJson());

  static UserModel fromJsonString(String raw) => UserModel.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
}
