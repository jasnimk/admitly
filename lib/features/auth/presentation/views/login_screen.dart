import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/utils/app_logger.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/utils/validators.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/core/widgets/app_text_field.dart';
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

  void _showForgotPasswordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetCtx) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
          child: const _ForgotPasswordSheet(),
        ),
      ),
    );
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
          } else if (state is AuthAuthenticated ||
              state is AuthBiometricSetupAvailable ||
              state is AuthPendingVerification) {
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
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _showForgotPasswordSheet(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Forgot password?',
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: context.colors.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
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

class _ForgotPasswordSheet extends StatefulWidget {
  const _ForgotPasswordSheet();

  @override
  State<_ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<_ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (_, curr) => curr is AuthError || curr is AuthPasswordResetSent,
      listener: (ctx, state) {
        if (state is AuthPasswordResetSent) {
          appLogger.i('[ForgotPwd] success — closing sheet');
          Navigator.of(ctx).pop();
          AppSnackBar.show(context, 'Reset link sent. Check your email.', type: SnackBarType.success);
        } else if (state is AuthError) {
          appLogger.w('[ForgotPwd] showing inline error: ${state.message}');
          setState(() => _errorMessage = state.message);
        }
      },
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 20.h),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reset Password',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            "We'll send a reset link to your email",
                            style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.fog),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, size: 20.w, color: colors.grey),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                AppTextField(
                  hint: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: Validators.email,
                  onChanged: (_) { if (_errorMessage != null) setState(() => _errorMessage = null); },
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.error_outline_rounded, size: 14.w, color: colors.red),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 20.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (ctx, state) => AppButton(
                    label: 'Send Reset Link',
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ctx.read<AuthBloc>().add(
                              AuthPasswordResetRequested(_emailCtrl.text.trim()),
                            );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
