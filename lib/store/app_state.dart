import '../models/shift.dart';

class AppState {
  final List<Shift> shifts;

  AppState({required this.shifts});

  AppState copyWith({List<Shift>? shifts}) {
    return AppState(
      shifts: shifts ?? this.shifts,
    );
  }

  factory AppState.initial() {
    return AppState(shifts: []);
  }
}