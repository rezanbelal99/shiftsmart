import '../../models/shift.dart';
import '../actions/shift_actions.dart';

List<Shift> shiftReducer(List<Shift> state, dynamic action) {
  if (action is SetShiftsAction) {
    return action.shifts;
  }
  return state;
}