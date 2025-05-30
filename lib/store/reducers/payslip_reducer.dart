import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/actions/payslip_actions.dart';

List<Payslip> payslipReducer(List<Payslip> state, dynamic action) {
  if (action is AddPayslipAction) {
    return List.from(state)..add(action.payslip);
  } else if (action is DeletePayslipAction) {
    return List.from(state)..removeAt(action.index);
  }
  return state;
}