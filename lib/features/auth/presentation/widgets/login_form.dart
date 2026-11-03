import 'package:admitly/core/utils/validators.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_text_field.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          AppTextField(
            hint: 'Email',
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: Validators.email,
          ),
          SizedBox(height: 10.h),
          AppTextField(
            hint: 'Password',
            controller: passwordController,
            obscureText: true,
            textInputAction: TextInputAction.done,
            validator: Validators.password,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          SizedBox(height: 20.h),
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) => AppButton(
              label: 'Sign In',
              onPressed: onSubmit,
              isLoading: state is AuthLoading,
            ),
          ),
        ],
      ),
    );
  }
}
