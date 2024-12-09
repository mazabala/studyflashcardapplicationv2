import 'package:flashcardstudyapplication/core/ui/widgets/CustomDialog.dart';
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

  Future<void> _signWithGoogle() async {
    final authNotifier = ref.read(authProvider.notifier);
    await authNotifier.googleSignin();
    
    final isAuthed = ref.read(authProvider).isAuthenticated;
    if(isAuthed) {
      Navigator.popAndPushNamed(context, '/myDecks');
    }
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                Text(
                  'Sign In',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF002B5C),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'Enter your email',
                  validator: _validateEmail,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter your password',
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  enabled: !authState.isLoading,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (authState.errorMessage != null)
                  ErrorMessage(message: authState.errorMessage!),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 100,
                      child: CustomButton(
                        text: 'Sign In',
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : () async => await _handleSubmit(false),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: CustomButton(
                        text: 'Google',
                        isLoading: authState.isLoading,
                        onPressed: _signWithGoogle,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: CustomButton(
                        text: 'Sign Up',
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading ? null : () => _handleSubmit(true),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _onForgotPasswordTapped,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onForgotPasswordTapped() {
    final authWatcher = ref.watch(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => CustomDialogWidget(
        title: 'Forgot Password',
        dialogContent: [
          const Text('Enter your email address:'),
          CustomTextField(
            controller: resetEmailController,
            label: 'Email Address',
            hint: 'Enter your email address here',
          ),
          CustomButton(
            text: 'Reset Password',
            isLoading: authState.isLoading,
            onPressed: () {
              authWatcher.resetPassword(resetEmailController.text);
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }
}