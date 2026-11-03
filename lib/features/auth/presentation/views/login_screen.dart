import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_header.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_logo.dart';
import 'package:admitly/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:admitly/features/auth/presentation/widgets/login_form.dart';
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
          } else if (state is AuthAuthenticated || state is AuthBiometricSetupAvailable) {
            widget.onLoginSuccess?.call();
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 16.h),
                  const AuthLogo(),
                  SizedBox(height: 16.h),
                  const AuthHeader(
                    title: 'Welcome back',
                    subtitle: 'Sign in to continue',
                  ),
                  SizedBox(height: 24.h),
                  LoginForm(
                    formKey: _formKey,
                    emailController: _emailController,
                    passwordController: _passwordController,
                    onSubmit: _submit,
                  ),
                  SizedBox(height: 10.h),
                  const GoogleSignInButton(),
                  SizedBox(height: 20.h),
                  AuthFooterLink(
                    message: "Don't have an account? ",
                    actionLabel: 'Register',
                    onTap: widget.onRegisterTap,
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
