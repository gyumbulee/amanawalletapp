import 'package:equatable/equatable.dart';

/// Domain-level user representation — what the rest of the app (screens,
/// other features) depends on. Deliberately decoupled from the JSON shape
/// the API returns; [AuthUserModel] in the data layer handles that mapping.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.referralCode,
    required this.isEmailVerified,
    this.avatarUrl,
    this.hasTransactionPin = false,
    this.isBvnVerified = false,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final String referralCode;
  final bool isEmailVerified;
  final String? avatarUrl;
  final bool hasTransactionPin;
  final bool isBvnVerified;

  AuthUser copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    bool? isEmailVerified,
    bool? hasTransactionPin,
    bool? isBvnVerified,
  }) {
    return AuthUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      referralCode: referralCode,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hasTransactionPin: hasTransactionPin ?? this.hasTransactionPin,
      isBvnVerified: isBvnVerified ?? this.isBvnVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        referralCode,
        isEmailVerified,
        avatarUrl,
        hasTransactionPin,
        isBvnVerified,
      ];
}
