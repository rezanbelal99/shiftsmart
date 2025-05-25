import '../app_state.dart';
import 'shift_reducer.dart';

AppState appReducer(AppState state, dynamic action) {
  // Add sub-reducers here
  return AppState(
    shifts: shiftReducer(state.shifts, action),
  );
}