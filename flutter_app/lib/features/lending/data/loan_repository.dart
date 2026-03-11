import '../../../services/api/api_client.dart';
import 'loan_models.dart';

class LoanRepository {
  const LoanRepository();

  Future<List<Loan>> getLoans({String? status, int page = 1, int limit = 20}) async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>(
      '/loans',
      queryParameters: {
        if (status != null) 'status': status,
        'page': page,
        'limit': limit,
      },
    );
    final list = data['data'] as List<dynamic>;
    return list.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<({Loan loan, List<Repayment> repayments})> getLoanDetail(String id) async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/$id');
    final inner = data['data'] as Map<String, dynamic>;
    return (
      loan: Loan.fromJson(inner['loan'] as Map<String, dynamic>),
      repayments: (inner['repayments'] as List<dynamic>)
          .map((e) => Repayment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<LoanSummary> getSummary() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/loans/summary');
    return LoanSummary.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<Loan> createLoan(CreateLoanPayload payload) async {
    final data = await ApiClient.instance.post<Map<String, dynamic>>(
      '/loans',
      data: payload.toJson(),
    );
    return Loan.fromJson(data['data'] as Map<String, dynamic>);
  }

  Future<({Loan loan, double newTrustScore})> markRepaid(String id, {String? note}) async {
    final data = await ApiClient.instance.patch<Map<String, dynamic>>(
      '/loans/$id/repay',
      data: {if (note != null) 'note': note},
    );
    return (
      loan: Loan.fromJson(data['data'] as Map<String, dynamic>),
      newTrustScore: (data['newTrustScore'] as num).toDouble(),
    );
  }

  Future<({Loan loan, double newTrustScore})> markDefaulted(String id) async {
    final data = await ApiClient.instance.patch<Map<String, dynamic>>('/loans/$id/default');
    return (
      loan: Loan.fromJson(data['data'] as Map<String, dynamic>),
      newTrustScore: (data['newTrustScore'] as num).toDouble(),
    );
  }

  Future<void> deleteLoan(String id) => ApiClient.instance.delete('/loans/$id');

  Future<TrustScoreData> getTrustScore() async {
    final data = await ApiClient.instance.get<Map<String, dynamic>>('/users/me/score');
    return TrustScoreData.fromJson(data['data'] as Map<String, dynamic>);
  }
}
