// lib/store/reducers/app_reducer.dart
import '../app_state.dart';
import 'shift_reducer.dart';
import 'payslip_reducer.dart';
import 'auth_reducer.dart'; // Reducer for authentication actions

/// Root reducer that applies authReducer first, then other sub-reducers.
AppState appReducer(AppState state, dynamic action) {
  // First apply authentication reducer to update user & authStatus
  final authState = authReducer(state, action);

  // Then apply sub-reducers for other domains, carrying forward authState
  return AppState(
    shifts: shiftReducer(authState.shifts, action),         // handle shift actions
    payslips: payslipReducer(authState.payslips, action),  // handle payslip actions
    user: authState.user,                                   // updated by authReducer
    authStatus: authState.authStatus,                       // updated by authReducer
  );
}