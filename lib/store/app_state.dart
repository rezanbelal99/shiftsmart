import '../models/shift.dart';
import '../models/payslip.dart';

class AppState {
  final List<Shift> shifts;
  final List<Payslip> payslips;

  AppState({required this.shifts, required this.payslips});

  AppState copyWith({List<Shift>? shifts, List<Payslip>? payslips}) {
    return AppState(
      shifts: shifts ?? this.shifts,
      payslips: payslips ?? this.payslips,
    );
  }

  factory AppState.initial() {
    return AppState(shifts: [], payslips: []);
  }
}