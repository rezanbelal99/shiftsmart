

// lib/screens/auth/login.dart
// Login screen with email/password fields and Redux dispatch

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../store/app_state.dart';
import '../../store/actions/auth_actions.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (context, vm) => Scaffold(
        appBar: AppBar(title: Text('Login')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              vm.isLoading
                  ? CircularProgressIndicator() // Show loading during login
                  : ElevatedButton(
                      onPressed: () => vm.onLogin(
                        _emailController.text.trim(),
                        _passwordController.text.trim(),
                      ),
                      child: Text('Login'),
                    ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ViewModel for LoginScreen to expose loading state and dispatch function
class _ViewModel {
  final bool isLoading;
  final void Function(String email, String password) onLogin;

  _ViewModel({required this.isLoading, required this.onLogin});

  factory _ViewModel.create(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.authStatus == AuthStatus.loading,
      onLogin: (email, password) =>
          store.dispatch(LoginRequested(email, password)),
    );
  }
}