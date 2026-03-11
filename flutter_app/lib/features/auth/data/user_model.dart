import 'dart:convert';

class User {
  const User({
    required this.id,
    required this.name,
    required this.trustScore,
    this.email,
    this.phone,
    this.profilePicture,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double trustScore;
  final String? email;
  final String? phone;
  final String? profilePicture;
  final DateTime createdAt;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['_id'] as String,
        name: json['name'] as String,
        trustScore: (json['trustScore'] as num).toDouble(),
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        profilePicture: json['profilePicture'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'trustScore': trustScore,
        'email': email,
        'phone': phone,
        'profilePicture': profilePicture,
        'createdAt': createdAt.toIso8601String(),
      };

  String toJsonString() => jsonEncode(toJson());

  factory User.fromJsonString(String raw) => User.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );

  User copyWith({
    String? name,
    double? trustScore,
    String? email,
    String? phone,
    String? profilePicture,
  }) =>
      User(
        id: id,
        name: name ?? this.name,
        trustScore: trustScore ?? this.trustScore,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        profilePicture: profilePicture ?? this.profilePicture,
        createdAt: createdAt,
      );
}

class AuthTokens {
  const AuthTokens({required this.token, required this.user});

  final String token;
  final User user;

  factory AuthTokens.fromJson(Map<String, dynamic> json) => AuthTokens(
        token: json['token'] as String,
        user: User.fromJson(json['user'] as Map<String, dynamic>),
      );
}
