

// lib/store/reducers/auth_reducer.dart
// Reducer for authentication actions

import 'package:redux/redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../actions/auth_actions.dart';
import '../app_state.dart';

/// Combines all auth-related reducers into one.
final authReducer = combineReducers<AppState>([
  TypedReducer<AppState, AuthStateChanged>(_setAuthState),
]);

/// Updates the AppState with the new Firebase [User] and [AuthStatus].
AppState _setAuthState(AppState state, AuthStateChanged action) {
  final user = action.user;
  final status = user != null
      ? AuthStatus.authenticated
      : AuthStatus.unauthenticated;
  return state.copyWith(
    user: user,
    authStatus: status,
  );
}