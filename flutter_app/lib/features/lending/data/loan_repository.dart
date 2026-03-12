import '../../../services/api/api_client.dart';
import 'loan_models.dart';
import '../../../core/models/loan_model.dart';
import '../../../core/models/repayment_model.dart';

class LoanRepository {
  const LoanRepository();

  Future<List<LoanModel>> getLoanModels({String? status, int page = 1, int limit = 20}) async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>(
      '/loans',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final list = data['data'] as List<dynamic>;
    return list.map((e) => LoanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({LoanModel loan, List<RepaymentModel> repayments})> getLoanModelDetail(String id) async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/$id');
    final inner = data['data'] as Map<String, dynamic>;
    return (
      loan: LoanModel.fromJson(inner['loan'] as Map<String, dynamic>),
      repayments: (inner['repayments'] as List<dynamic>)
          .map((e) => RepaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<LoanModelSummary> getSummary() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/summary');
    return LoanModelSummary.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<LoanModel> createLoanModelRequest(CreateLoanModelPayload payload) async {
    final data = await ApiClient.instance.post<Map<String, dynamic>>(
      '/loans/requests',
      data: payload.toJson(),
    );
    return LoanModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<List<LoanModel>> getIncomingRequests() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/requests/incoming');
    final list = data['data'] as List<dynamic>;
    return list.map((e) => LoanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<LoanModel>> getOutgoingRequests() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/requests/outgoing');
    final list = data['data'] as List<dynamic>;
    return list.map((e) => LoanModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LoanModel> acceptLoanModelRequest(String id) async {
    final data = await ApiClient.instance.post<Map<String, dynamic>>('/loans/requests/$id/accept');
    return LoanModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<LoanModel> rejectLoanModelRequest(String id) async {
    final data = await ApiClient.instance.post<Map<String, dynamic>>('/loans/requests/$id/reject');
    return LoanModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<LoanModel> cancelLoanModelRequest(String id) async {
    final data = await ApiClient.instance.post<Map<String, dynamic>>('/loans/requests/$id/cancel');
    return LoanModel.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<({LoanModel loan, double newTrustScore})> markRepaid(String id, {String? note}) async {
    final data = await ApiClient.instance.patch<Map<String, dynamic>>(
      '/loans/$id/repay',
      data: {if (note != null) 'note': note},
    );
    return (
      loan: LoanModel.fromJson(data['data'] as Map<String, dynamic>),
      newTrustScore: (data['newTrustScore'] as num).toDouble(),
    );
  }

  Future<({LoanModel loan, double newTrustScore})> markDefaulted(String id) async {
    final data = await ApiClient.instance.patch<Map<String, dynamic>>('/loans/$id/default');
    return (
      loan: LoanModel.fromJson(data['data'] as Map<String, dynamic>),
      newTrustScore: (data['newTrustScore'] as num).toDouble(),
    );
  }

  Future<void> deleteLoanModel(String id) => ApiClient.instance.delete('/loans/$id');

  Future<TrustScoreData> getTrustScore() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/users/me/score');
    return TrustScoreData.fromJson(data['data'] as Map<String, dynamic>);
  }
}
