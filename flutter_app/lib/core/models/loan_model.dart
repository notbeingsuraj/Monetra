import 'package:freezed_annotation/freezed_annotation.dart';

part 'loan_model.freezed.dart';
part 'loan_model.g.dart';

enum LoanStatus {
  pending,
  active,
  rejected,
  repaid,
  overdue,
  defaulted,
  cancelled,
  expired
}

@freezed
class LoanModel with _$LoanModel {
  const factory LoanModel({
    @JsonKey(name: '_id') required String id,
    required String lenderId,
    String? borrowerId,
    required String borrowerName,
    String? borrowerContact,
    required double amount,
    @Default(0) double interest,
    @Default('INR') String currency,
    required DateTime dueDate,
    String? note,
    required LoanStatus status,
    DateTime? expiresAt,
    DateTime? repaidAt,
    @Default(0) int lateDays,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LoanModel;

  factory LoanModel.fromJson(Map<String, dynamic> json) => _$LoanModelFromJson(json);
}
