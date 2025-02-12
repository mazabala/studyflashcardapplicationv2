import 'dart:developer';

import 'package:flashcardstudyapplication/core/ui/widgets/CustomDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flashcardstudyapplication/core/providers/provider_config.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomScaffold.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomTextField.dart';
import 'package:flashcardstudyapplication/core/ui/widgets/CustomButton.dart';


class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
 
  static final   _formKey = GlobalKey<FormState>();
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
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.googleSignin();


    final isAuthed = ref.read(authStateProvider).isAuthenticated;


    if (isAuthed) {
      Navigator.pushReplacementNamed(context, '/myDecks');
    }
  }

  Future<void> _signInWithApple() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    await authNotifier.signInWithApple();


    final isAuthed = ref.read(authStateProvider).isAuthenticated;


    if (isAuthed) {
      Navigator.pushReplacementNamed(context, '/myDecks');
    }
  }






  Future<void> _handleSubmit(bool isSignUp) async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final authNotifier = ref.read(authStateProvider.notifier);

    try {
      if (isSignUp) {
        final signUpEmailController = TextEditingController();
        final signUpPasswordController = TextEditingController();
        final signUpNameController = TextEditingController();
        final signUpLastNameController = TextEditingController();

        showDialog(
          context: context,
          builder: (context) => CustomDialogWidget(
            title: 'Register',
            dialogContent: [
              const Text('Enter your name:'),
              CustomTextField(
                controller: signUpNameController,
                label: 'Name',
                hint: 'Enter your name here',
              ),
              const Text('Enter your last name:'),
              CustomTextField(
                controller: signUpLastNameController,
                label: 'Last Name',
                hint: 'Enter your last name here',
              ),
              const Text('Enter your email address:'),
              CustomTextField(
                controller: signUpEmailController,
                label: 'Email Address',
                hint: 'Enter your email address here',
              ),
              const Text('Enter password:'),
              CustomTextField(
                controller: signUpPasswordController,
                label: 'Password',
                hint: 'Enter your password here',
              ),
              const SizedBox(width: 10),
              CustomButton(
                text: 'Finish',
                isLoading: false,
                onPressed: () async {
                  await authNotifier.signUp(
                      signUpEmailController.text,
                      signUpPasswordController.text,
                      signUpNameController.text,
                      signUpLastNameController.text); //TODO: VERIFY THIS WORKS

                  if (mounted) {
                    Navigator.of(context).pop();
                  }
// Close the dialog after reset
                },
              ),
            ],
          ),
        );
      } else {
        await authNotifier.signIn(email, password);
      }

      // Add a small delay to ensure initialization
      await Future.delayed(const Duration(milliseconds: 500));

      final authState = ref.read(authStateProvider);

      if (authState.isAuthenticated) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/myDecks');
        }
      }
    } catch (e) {
      if (mounted) {
        log(e.toString());
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      } else
        dispose();
    }
  }

void _onForgotPasswordTapped() {
    final authWatcher = ref.watch(authStateProvider.notifier);
    final authState = ref.watch(authStateProvider);
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
// Close the dialog after reset
            },
          ),
        ],
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isWeb = size.width > 800;
    final authState = ref.watch(authStateProvider);
 


    Widget loginForm = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isWeb) const SizedBox(height: 40),
          if (!isWeb) const Center(
            child: Text(
              'Log in',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (!isWeb) const SizedBox(height: 20),
          CustomButton(
            text: 'Continue with Apple',
            isLoading: false,
            onPressed: () {_signInWithApple();},
          ),
          const SizedBox(height: 12),
          CustomButton(
            text: 'Continue with Google',
            isLoading: false,
            onPressed: () {_signWithGoogle();},
          ),
          const SizedBox(height: 24),
          const Center(child: Text('OR')),
          const SizedBox(height: 24),
          CustomTextField(
            controller: _emailController,
            label: 'Email Address',
            hint: 'Enter your email',
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1),
              ),
            ),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(width: 1),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Log In',
            isLoading: authState.isLoading,
            onPressed: () {_handleSubmit(false);},
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () {_handleSubmit(true);},
              child: const Text('Dont have an account? Register Here!'),
            ),
          ),
          const SizedBox(height: 2),
          Center(
            child: TextButton(
              onPressed: () {_onForgotPasswordTapped();},
              child: const Text('Forgot your password?'),
            ),
          ),
          if (!isWeb) const SizedBox(height: 16),
          if (!isWeb) Center(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black87),
                children: [
                  const TextSpan(text: 'By continuing, you agree to Haniel '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (isWeb) {
      return CustomScaffold(
        currentRoute: '/login',
        body: Row(
          children: [
            // Left side - Image
            Expanded(
              child: Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Text('Placeholder for landscape image'),
                ),
              ),
            ),
            // Right side - Login form
            Container(
              width: 400,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Nice to see you again',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 40),
                  loginForm,
                ],
              ),
            ),
          ],
        ),
      );
    }

    return CustomScaffold(
      currentRoute: '/login',
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: loginForm,
        ),
      ),
    );
  }
}