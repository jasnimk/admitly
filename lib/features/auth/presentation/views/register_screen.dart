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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, this.onLoginTap, this.onRegisterSuccess});

  final VoidCallback? onLoginTap;
  final VoidCallback? onRegisterSuccess;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
          email: _emailController.text,
          password: _passwordController.text,
          name: _nameController.text,
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
            widget.onRegisterSuccess?.call();
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 48.h),
                  GestureDetector(
                    onTap: widget.onLoginTap,
                    child: Icon(Icons.arrow_back_ios_new_rounded, size: 20.w, color: colors.text),
                  ),
                  SizedBox(height: 24.h),
                  Text('Create account',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      )),
                  SizedBox(height: 6.h),
                  Text('Register as a parent to begin the admission process',
                      style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey)),
                  SizedBox(height: 36.h),
                  AppTextField(
                    label: 'Full Name',
                    hint: 'Enter your full name',
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: Validators.name,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Email',
                    hint: 'Enter your email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: Validators.email,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Password',
                    hint: 'Minimum 6 characters',
                    controller: _passwordController,
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: Validators.password,
                  ),
                  SizedBox(height: 16.h),
                  AppTextField(
                    label: 'Confirm Password',
                    hint: 'Re-enter your password',
                    controller: _confirmPasswordController,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value != _passwordController.text) return 'Passwords do not match';
                      return null;
                    },
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  SizedBox(height: 32.h),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => AppButton(
                      label: 'Create Account',
                      onPressed: _submit,
                      isLoading: state is AuthLoading,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Already have an account? ',
                          style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey)),
                      GestureDetector(
                        onTap: widget.onLoginTap,
                        child: Text('Sign In',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            )),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
