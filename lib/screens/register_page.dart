import 'package:flutter/material.dart';
import 'package:smartagri/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String? _error;
  bool _isLoading = false;

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      try {
        final user = await _authService.signUp(_email, _password);
        if (!mounted) return;
        if (user != null) {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _error = 'Registration failed: No user returned';
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
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.teal,
      ),
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
                        value!.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 20),
              if (_error != null)
                Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Register'),
                  ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
