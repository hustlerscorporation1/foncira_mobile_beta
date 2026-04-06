import 'user.dart';

class AuthResponse {
  final User user;
  final String? accessToken;

  AuthResponse({
    required this.user,
    this.accessToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json),
      accessToken: json['access_token'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...user.toJson(),
      if (accessToken != null) 'access_token': accessToken,
    };
  }
}

