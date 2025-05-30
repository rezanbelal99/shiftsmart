

// Middleware to handle authentication actions via FirebaseAuth
import 'package:redux/redux.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../actions/auth_actions.dart';
import '../app_state.dart';

/// Intercepts auth-related actions and forwards to Firebase,
/// then dispatches AuthStateChanged to update the store.
void authMiddleware(Store<AppState> store, dynamic action, NextDispatcher next) {
  if (action is LoginRequested) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
          email: action.email,
          password: action.password,
        )
        .then((result) {
      store.dispatch(AuthStateChanged(result.user));
    }).catchError((error) {
      // TODO: handle login error (e.g., dispatch an error action or show notification)
    });
  } else if (action is RegisterRequested) {
    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: action.email,
          password: action.password,
        )
        .then((result) {
      store.dispatch(AuthStateChanged(result.user));
    }).catchError((error) {
      // TODO: handle registration error
    });
  } else if (action is LogoutRequested) {
    FirebaseAuth.instance.signOut().then((_) {
      store.dispatch(AuthStateChanged(null));
    }).catchError((error) {
      // TODO: handle logout error
    });
  }
  
  // Make sure to pass action along to next middleware/reducer
  next(action);
}