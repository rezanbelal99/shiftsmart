

// Defines authentication action classes for Redux

import 'package:firebase_auth/firebase_auth.dart';

/// Action: Trigger a login with email and password
class LoginRequested {
  final String email;
  final String password;
  LoginRequested(this.email, this.password);
}

/// Action: Trigger a registration with email, password, and role
class RegisterRequested {
  final String email;
  final String password;
  final String role;
  RegisterRequested(this.email, this.password, this.role);
}

/// Action: Handles changes to the authentication state
class AuthStateChanged {
  final User? user;
  AuthStateChanged(this.user);
}

/// Action: Trigger a logout
class LogoutRequested {}