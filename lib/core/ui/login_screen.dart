
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!value.contains('@')) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> _handleSubmit(bool isSignUp) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Get the AuthNotifier from provider
    final authNotifier = ref.read(authProvider.notifier);

    try {
      if (isSignUp) {
        await authNotifier.signUp(email, password);
      } else {
        await authNotifier.signIn(email, password);
      }

      // After successful login, check if the user is authenticated
      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        // Use `mounted` check before navigating
        if (mounted) {
          
          Navigator.pushReplacementNamed(context, '/myDecks');
          
          
        }
      }
    } catch (e) {
      // Error handling delegated to provider, just show snackbar if needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state changes
    final authState = ref.watch(authProvider);

    return CustomScaffold(
      currentRoute: '/login',
      body: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Sign In',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 20),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                validator: _validateEmail,
                enabled: !authState.isLoading,
              ),
              
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: _validatePassword,
                enabled: !authState.isLoading,
              ),
              
              const SizedBox(height: 20),
              
              if (authState.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    authState.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authState.isLoading 
                        ? null 
                        : () => _handleSubmit(false),
                      child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign In'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: authState.isLoading 
                        ? null 
                        : () => _handleSubmit(true),
                      child: authState.isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign Up'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
