import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/contact_method_toggle.dart';
import '../widgets/primary_button.dart';
import '../widgets/social_login_row.dart';
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
  bool _isLoading = false;

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

  void _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: replace with your backend call (Yosef's API) via your Bloc/Cubit.
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() => _isLoading = false);
    if (!mounted) return;

    // TODO: navigate to the home screen (the one with the emergency button)
    // once that route exists, e.g.:
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
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
                      // TODO: navigate to forgot-password flow
                    },
                    child: const Text('Forgot password?', style: AppTextStyles.linkRed),
                  ),
                ),

                const SizedBox(height: 40),
                PrimaryButton(
                  label: 'Login',
                  isLoading: _isLoading,
                  onPressed: _onLoginPressed,
                ),
                const SizedBox(height: 24),
                SocialLoginRow(
                  onGooglePressed: () {
                    // TODO: hook up Google sign-in
                  },
                  onFacebookPressed: () {
                    // TODO: hook up Facebook sign-in
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
  }
}