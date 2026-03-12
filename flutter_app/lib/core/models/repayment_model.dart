import 'package:freezed_annotation/freezed_annotation.dart';

part 'repayment_model.freezed.dart';
part 'repayment_model.g.dart';

@freezed
class RepaymentModel with _$RepaymentModel {
  const factory RepaymentModel({
    @JsonKey(name: '_id') required String id,
    required String loanId,
    required String lenderId,
    required double amountPaid,
    required DateTime paidAt,
    String? note,
  }) = _RepaymentModel;

  factory RepaymentModel.fromJson(Map<String, dynamic> json) => _$RepaymentModelFromJson(json);
}
