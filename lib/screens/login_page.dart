import 'package:flutter/material.dart';
import 'package:smartagri/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _error;
  bool _isLoading = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final user = await _authService.signIn(_email, _password);
        if (!mounted) return;
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _error = 'Login failed: No user returned';
            _isLoading = false;
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (value) => value!.isEmpty ? 'Email cannot be empty' : null,
                onChanged: (value) => _email = value.trim(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator:
                    (value) =>
                        value!.isEmpty ? 'Password cannot be empty' : null,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _login,
                    child: const Text('Login'),
                  ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
