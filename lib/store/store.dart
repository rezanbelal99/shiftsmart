// lib/store/store.dart
import 'package:redux/redux.dart';
import 'package:shiftsmart/models/shift.dart';
import 'package:shiftsmart/models/payslip.dart';
import 'package:shiftsmart/store/app_state.dart';
import 'package:shiftsmart/store/reducers/shift_reducer.dart';
import 'package:shiftsmart/store/reducers/payslip_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  // Preserve authentication state, then apply sub-reducers
  return AppState(
    user: state.user,                     // current Firebase user
    authStatus: state.authStatus,         // current authentication status
    shifts: shiftReducer(state.shifts, action),
    payslips: payslipReducer(state.payslips, action),
  );
}

final Store<AppState> store = Store<AppState>(
  appReducer,
  initialState: AppState.initial(),
);