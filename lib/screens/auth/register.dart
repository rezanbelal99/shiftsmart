

// lib/screens/auth/register.dart
// Registration screen with email, password, confirm password, and role selection

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import '../../store/app_state.dart';
import '../../store/actions/auth_actions.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = '/register';
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String _selectedRole = 'employee'; // Default role

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, _ViewModel>(
      distinct: true,
      converter: (Store<AppState> store) => _ViewModel.create(store),
      builder: (context, vm) => Scaffold(
        appBar: AppBar(title: Text('Register')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              TextField(
                controller: _confirmController,
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                items: [
                  DropdownMenuItem(value: 'employee', child: Text('Employee')),
                  DropdownMenuItem(value: 'employer', child: Text('Employer')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _selectedRole = value);
                },
                decoration: InputDecoration(labelText: 'Role'),
              ),
              const SizedBox(height: 24),
              vm.isLoading
                  ? CircularProgressIndicator() // Show loading during registration
                  : ElevatedButton(
                      onPressed: () {
                        if (_passwordController.text != _confirmController.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Passwords do not match')),
                          );
                        } else {
                          vm.onRegister(
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            _selectedRole,
                          );
                        }
                      },
                      child: Text('Register'),
                    ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, LoginScreen.routeName),
                child: Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ViewModel for RegisterScreen to expose loading state and dispatch function
class _ViewModel {
  final bool isLoading;
  final void Function(String email, String password, String role) onRegister;

  _ViewModel({required this.isLoading, required this.onRegister});

  factory _ViewModel.create(Store<AppState> store) {
    return _ViewModel(
      isLoading: store.state.authStatus == AuthStatus.loading,
      onRegister: (email, password, role) =>
          store.dispatch(RegisterRequested(email, password, role)),
    );
  }
}