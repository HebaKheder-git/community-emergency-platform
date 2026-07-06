// EDITED — wired to POST /auth/login.
//
// Scenario/backend mismatch: /auth/login only accepts {email, password}.
// There is no phone-based login endpoint yet, so — same treatment as
// SignUpScreen — the Phone pill stays in the UI but is blocked at submit
// time with a clear message.
//
// "Forgot password?" now navigates to the new ForgotPasswordEmailScreen
// (see linking notes — there was no screen in the original set that lets
// an unauthenticated user type the email/phone to start a reset).
//
// On success, this pushes-and-clears to HomeScreen: swap that import if
// your actual home route differs.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubits/auth/auth_cubit.dart';
import '../cubits/auth/auth_state.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/contact_method_toggle.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_login_row.dart';
import 'forgot_password_email_screen.dart';
import 'home_screen.dart';
import 'sign_up_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  ContactMethod _method = ContactMethod.email;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _method == ContactMethod.email
          ? 'Please enter your email'
          : 'Please enter your phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    return null;
  }

  void _onLoginPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_method == ContactMethod.phone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login with phone isn\'t available yet — please use email.'),
        ),
      );
      return;
    }

    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.loggedIn) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen()),
              (_) => false,
            );
          } else if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == AuthStatus.loading;
          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      RichText(
                        text: const TextSpan(
                          style: AppTextStyles.heading,
                          children: [
                            TextSpan(text: "Let's sign you in"),
                            TextSpan(text: '.', style: TextStyle(color: AppColors.primaryRed)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Welcome back.', style: AppTextStyles.subtitle),
                      const SizedBox(height: 28),

                      ContactMethodToggle(
                        selected: _method,
                        onChanged: (method) => setState(() => _method = method),
                      ),
                      const SizedBox(height: AppSpacing.smallGap),
                      if (_method == ContactMethod.email)
                        AuthTextField(
                          key: const ValueKey('email_field'),
                          controller: _emailController,
                          hintText: 'Your email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateContact,
                        )
                      else
                        AuthTextField(
                          key: const ValueKey('phone_field'),
                          controller: _phoneController,
                          hintText: 'Your phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: _validateContact,
                        ),
                      const SizedBox(height: AppSpacing.fieldGap),

                      const Text('Password', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: AppSpacing.smallGap),
                      AuthTextField(
                        controller: _passwordController,
                        hintText: 'Enter password',
                        icon: Icons.lock_outline,
                        obscureText: true,
                        validator: _validatePassword,
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordEmailScreen(),
                              ),
                            );
                          },
                          child: const Text('Forgot password?', style: AppTextStyles.linkRed),
                        ),
                      ),

                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Login',
                        isLoading: isLoading,
                        onPressed: () => _onLoginPressed(context),
                      ),
                      const SizedBox(height: 24),
                      SocialLoginRow(
                        onGooglePressed: () {
                          // TODO: not implemented in backend yet.
                        },
                        onFacebookPressed: () {
                          // TODO: not implemented in backend yet.
                        },
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.footerText,
                            children: [
                              const TextSpan(text: 'Are you new here? '),
                              TextSpan(
                                text: 'Sign up',
                                style: AppTextStyles.linkRed,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}