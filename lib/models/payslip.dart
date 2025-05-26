


class Payslip {
  final String employer;
  final String period;
  final double hoursWorked;
  final double grossPay;
  final double netPay;
  final String paymentDate;

  Payslip({
    required this.employer,
    required this.period,
    required this.hoursWorked,
    required this.grossPay,
    required this.netPay,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'employer': employer,
      'period': period,
      'hoursWorked': hoursWorked,
      'grossPay': grossPay,
      'netPay': netPay,
      'paymentDate': paymentDate,
    };
  }

  factory Payslip.fromMap(Map<String, dynamic> map) {
    return Payslip(
      employer: map['employer'] ?? '',
      period: map['period'] ?? '',
      hoursWorked: double.tryParse(map['hoursWorked'].toString()) ?? 0.0,
      grossPay: double.tryParse(map['grossPay'].toString()) ?? 0.0,
      netPay: double.tryParse(map['netPay'].toString()) ?? 0.0,
      paymentDate: map['paymentDate'] ?? '',
    );
  }
}