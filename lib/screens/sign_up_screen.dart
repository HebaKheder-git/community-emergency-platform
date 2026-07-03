// EDITED — wired to POST /auth/register.
//
// Scenario/backend mismatch: /auth/register only accepts {name, email,
// password, password_confirmation}. There is no phone-based registration
// endpoint yet, so the Phone pill is kept in the UI (per your Figma) but
// blocked at submit time with a clear message instead of silently being
// sent as if it worked. Swap the TODO block for real phone support once
// Yosef adds it.
//
// Google / Facebook buttons are left as TODOs, per your note that those
// aren't implemented in the backend yet.

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
import 'otp_verification_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  ContactMethod _method = ContactMethod.email;

  bool get _showConfirmPassword => _passwordController.text.isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'Please enter your name';
    return null;
  }

  String? _validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return _method == ContactMethod.email
          ? 'Please enter your email'
          : 'Please enter your phone number';
    }
    if (_method == ContactMethod.email) {
      final emailRegex = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
      if (!emailRegex.hasMatch(value)) return 'Enter a valid email address';
    } else {
      final phoneRegex = RegExp(r'^\+?[0-9]{8,15}$');
      if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (!_showConfirmPassword) return null;
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }

  void _onSignUpPressed(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_method == ContactMethod.phone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign up with phone isn\'t available yet — please use email.'),
        ),
      );
      return;
    }

    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.registerAwaitingOtp) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OtpVerificationScreen(
                  verificationType: OtpVerificationType.email,
                  destination: _emailController.text.trim(),
                  tempToken: state.tempToken!,
                ),
              ),
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
                            TextSpan(text: "Let's sign you up"),
                            TextSpan(text: '.', style: TextStyle(color: AppColors.primaryRed)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text('Welcome.', style: AppTextStyles.subtitle),
                      const SizedBox(height: 28),

                      const Text('Full Name', style: AppTextStyles.fieldLabel),
                      const SizedBox(height: AppSpacing.smallGap),
                      AuthTextField(
                        controller: _nameController,
                        hintText: 'Your name',
                        icon: Icons.person_outline,
                        validator: _validateName,
                      ),
                      const SizedBox(height: AppSpacing.fieldGap),

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
                        onChanged: (_) => setState(() {}),
                      ),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _showConfirmPassword
                            ? Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.fieldGap),
                                child: AuthTextField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm password',
                                  icon: Icons.lock_outline,
                                  obscureText: true,
                                  validator: _validateConfirmPassword,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 40),
                      PrimaryButton(
                        label: 'Sign up',
                        isLoading: isLoading,
                        onPressed: () => _onSignUpPressed(context),
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
                              const TextSpan(text: 'Already a member? '),
                              TextSpan(
                                text: 'Log in',
                                style: AppTextStyles.linkRed,
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (_) => const LoginScreen()),
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
