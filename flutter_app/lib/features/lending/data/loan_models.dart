enum LoanStatus { pending, active, rejected, repaid, overdue, defaulted, cancelled, expired }

extension LoanStatusX on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.pending: return 'Pending';
      case LoanStatus.active: return 'Active';
      case LoanStatus.rejected: return 'Rejected';
      case LoanStatus.repaid: return 'Repaid';
      case LoanStatus.overdue: return 'Overdue';
      case LoanStatus.defaulted: return 'Defaulted';
      case LoanStatus.cancelled: return 'Cancelled';
      case LoanStatus.expired: return 'Expired';
    }
  }

  static LoanStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'active': return LoanStatus.active;
      case 'rejected': return LoanStatus.rejected;
      case 'repaid': return LoanStatus.repaid;
      case 'overdue': return LoanStatus.overdue;
      case 'defaulted': return LoanStatus.defaulted;
      case 'cancelled': return LoanStatus.cancelled;
      case 'expired': return LoanStatus.expired;
      default: return LoanStatus.pending;
    }
  }
}

export '../../../core/models/loan_model.dart';
export '../../../core/models/repayment_model.dart';

class LoanSummary {
  const LoanSummary({
    required this.pending,
    required this.repaid,
    required this.overdue,
    required this.defaulted,
    required this.totalLent,
  });

  final int pending;
  final int repaid;
  final int overdue;
  final int defaulted;
  final double totalLent;

  factory LoanSummary.fromJson(Map<String, dynamic> j) => LoanSummary(
        pending: (j['pending'] as num).toInt(),
        repaid: (j['repaid'] as num).toInt(),
        overdue: (j['overdue'] as num).toInt(),
        defaulted: (j['defaulted'] as num).toInt(),
        totalLent: (j['totalLent'] as num).toDouble(),
      );
}

class TrustScoreData {
  const TrustScoreData({
    required this.baseScore,
    required this.loansRepaid,
    required this.defaults,
    required this.lateDays,
    required this.finalScore,
  });

  final double baseScore;
  final int loansRepaid;
  final int defaults;
  final int lateDays;
  final double finalScore;

  factory TrustScoreData.fromJson(Map<String, dynamic> j) => TrustScoreData(
        baseScore: (j['baseScore'] as num).toDouble(),
        loansRepaid: (j['loansRepaid'] as num).toInt(),
        defaults: (j['defaults'] as num).toInt(),
        lateDays: (j['lateDays'] as num).toInt(),
        finalScore: (j['finalScore'] as num).toDouble(),
      );
}

class CreateLoanPayload {
  const CreateLoanPayload({
    required this.borrowerName,
    this.borrowerContact,
    required this.amount,
    this.interest,
    this.currency = 'INR',
    required this.dueDate,
    this.note,
  });

  final String borrowerName;
  final String? borrowerContact;
  final double amount;
  final double? interest;
  final String currency;
  final String dueDate;
  final String? note;

  Map<String, dynamic> toJson() => {
        if (borrowerName.isNotEmpty) 'borrowerName': borrowerName,
        if (borrowerContact != null) 'borrowerContact': borrowerContact,
        'amount': amount,
        if (interest != null) 'interest': interest,
        'currency': currency,
        'dueDate': dueDate,
        if (note != null) 'note': note,
      };
}
