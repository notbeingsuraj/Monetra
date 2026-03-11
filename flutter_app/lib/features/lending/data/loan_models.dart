enum LoanStatus { pending, repaid, overdue, defaulted }

extension LoanStatusX on LoanStatus {
  String get label {
    switch (this) {
      case LoanStatus.pending:
        return 'Pending';
      case LoanStatus.repaid:
        return 'Repaid';
      case LoanStatus.overdue:
        return 'Overdue';
      case LoanStatus.defaulted:
        return 'Defaulted';
    }
  }

  static LoanStatus fromString(String s) {
    switch (s.toLowerCase()) {
      case 'repaid':
        return LoanStatus.repaid;
      case 'overdue':
        return LoanStatus.overdue;
      case 'defaulted':
        return LoanStatus.defaulted;
      default:
        return LoanStatus.pending;
    }
  }
}

class Loan {
  const Loan({
    required this.id,
    required this.lenderId,
    required this.borrowerName,
    this.borrowerContact,
    this.borrowerId,
    required this.amount,
    required this.currency,
    required this.dueDate,
    this.note,
    required this.status,
    this.repaidAt,
    required this.lateDays,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String lenderId;
  final String borrowerName;
  final String? borrowerContact;
  final String? borrowerId;
  final double amount;
  final String currency;
  final DateTime dueDate;
  final String? note;
  final LoanStatus status;
  final DateTime? repaidAt;
  final int lateDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Loan.fromJson(Map<String, dynamic> j) => Loan(
        id: j['_id'] as String,
        lenderId: j['lenderId'] as String,
        borrowerName: j['borrowerName'] as String,
        borrowerContact: j['borrowerContact'] as String?,
        borrowerId: j['borrowerId'] as String?,
        amount: (j['amount'] as num).toDouble(),
        currency: (j['currency'] as String?) ?? 'INR',
        dueDate: DateTime.parse(j['dueDate'] as String),
        note: j['note'] as String?,
        status: LoanStatusX.fromString(j['status'] as String),
        repaidAt: j['repaidAt'] != null ? DateTime.parse(j['repaidAt'] as String) : null,
        lateDays: (j['lateDays'] as num).toInt(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
      );
}

class Repayment {
  const Repayment({
    required this.id,
    required this.loanId,
    required this.lenderId,
    required this.amountPaid,
    this.note,
    required this.paidAt,
  });

  final String id;
  final String loanId;
  final String lenderId;
  final double amountPaid;
  final String? note;
  final DateTime paidAt;

  factory Repayment.fromJson(Map<String, dynamic> j) => Repayment(
        id: j['_id'] as String,
        loanId: j['loanId'] as String,
        lenderId: j['lenderId'] as String,
        amountPaid: (j['amountPaid'] as num).toDouble(),
        note: j['note'] as String?,
        paidAt: DateTime.parse(j['paidAt'] as String),
      );
}

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
    this.currency = 'INR',
    required this.dueDate,
    this.note,
  });

  final String borrowerName;
  final String? borrowerContact;
  final double amount;
  final String currency;
  final String dueDate;
  final String? note;

  Map<String, dynamic> toJson() => {
        'borrowerName': borrowerName,
        if (borrowerContact != null) 'borrowerContact': borrowerContact,
        'amount': amount,
        'currency': currency,
        'dueDate': dueDate,
        if (note != null) 'note': note,
      };
}
