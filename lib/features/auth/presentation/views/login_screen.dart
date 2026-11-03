import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/utils/validators.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/core/widgets/app_text_field.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onRegisterTap, this.onLoginSuccess});

  final VoidCallback? onRegisterTap;
  final VoidCallback? onLoginSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            AppSnackBar.show(context, state.message, type: SnackBarType.error);
          } else if (state is AuthAuthenticated) {
            widget.onLoginSuccess?.call();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.h),
                    // Logo
                    Image.asset(
                      colors.isDark
                          ? 'assets/logo/logo_dark.png'
                          : 'assets/logo/logo_light.png',
                      width: 72.w,
                      height: 72.w,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 16.h),
                    Text('Welcome back',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: colors.text,
                        )),
                    SizedBox(height: 4.h),
                    Text('Sign in to continue',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 13,
                          color: colors.grey,
                        )),
                    SizedBox(height: 24.h),
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                    ),
                    SizedBox(height: 10.h),
                    AppTextField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      validator: Validators.password,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    SizedBox(height: 20.h),
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) => AppButton(
                        label: 'Sign In',
                        onPressed: _submit,
                        isLoading: state is AuthLoading,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _GoogleSignInButton(),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 13, color: colors.grey)),
                        GestureDetector(
                          onTap: widget.onRegisterTap,
                          child: Text('Register',
                              style: AppTextStyles.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colors.text,
                              )),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => AppButton(
        label: 'Continue with Google',
        variant: AppButtonVariant.outlined,
        isLoading: false,
        onPressed: state is AuthLoading
            ? null
            : () => context.read<AuthBloc>().add(const AuthGoogleSignInRequested()),
        icon: Image.network(
          'https://www.google.com/favicon.ico',
          width: 16.w,
          height: 16.w,
          errorBuilder: (_, __, ___) =>
              Icon(Icons.g_mobiledata, color: colors.text, size: 20.w),
        ),
      ),
    );
  }
}
