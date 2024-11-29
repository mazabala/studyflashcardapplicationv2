import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashcardstudyapplication/core/providers/auth_provider.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomTextField.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/ErrorMessage.dart';

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
    final authNotifier = ref.read(authProvider.notifier);

    try {
      if (isSignUp) {
        await authNotifier.signUp(email, password);
      } else {
        await authNotifier.signIn(email, password);
      }

      final authState = ref.read(authProvider);
      if (authState.isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/myDecks');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
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
              CustomTextField(
                controller: _emailController,
                label: 'Email',
                hint: 'Enter your email',
                validator: _validateEmail,
                enabled: !authState.isLoading,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                obscureText: _obscurePassword,
                validator: _validatePassword,
                enabled: !authState.isLoading,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              const SizedBox(height: 20),
              if (authState.errorMessage != null)
                ErrorMessage(message: authState.errorMessage!),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Sign In',
                      isLoading: authState.isLoading,
                      onPressed: authState.isLoading ? null : () => _handleSubmit(false),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: 'Sign Up',
                      isLoading: authState.isLoading,
                      onPressed: authState.isLoading ? null : () => _handleSubmit(true),
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
