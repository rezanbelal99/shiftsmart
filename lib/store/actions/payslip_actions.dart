import 'package:shiftsmart/models/payslip.dart';

class AddPayslipAction {
  final Payslip payslip;

  AddPayslipAction(this.payslip);
}

class DeletePayslipAction {
  final int index;

  DeletePayslipAction(this.index);
}
