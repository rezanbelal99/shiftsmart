import '../models/shift.dart';
import '../models/payslip.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase user type

/// Represents the current authentication status
enum AuthStatus { loading, authenticated, unauthenticated, error }

class AppState {
  // Authentication state: Firebase user and status
  final User? user;
  final AuthStatus authStatus;
  final List<Shift> shifts;
  final List<Payslip> payslips;

  AppState({
    required this.user,
    required this.authStatus,
    required this.shifts,
    required this.payslips,
  });

  AppState copyWith({
    User? user,
    AuthStatus? authStatus,
    List<Shift>? shifts,
    List<Payslip>? payslips,
  }) {
    return AppState(
      user: user ?? this.user,
      authStatus: authStatus ?? this.authStatus,
      shifts: shifts ?? this.shifts,
      payslips: payslips ?? this.payslips,
    );
  }

  factory AppState.initial() {
    return AppState(
      user: null,
      authStatus: AuthStatus.loading,
      shifts: [],
      payslips: [],
    );
  }
}