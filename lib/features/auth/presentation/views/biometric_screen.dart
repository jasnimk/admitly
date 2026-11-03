import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_header.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_logo.dart';
import 'package:admitly/features/auth/presentation/widgets/biometric_prompt_button.dart';
import 'package:admitly/features/auth/presentation/widgets/biometric_use_password_link.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BiometricScreen extends StatefulWidget {
  const BiometricScreen({super.key, required this.user});

  final UserEntity user;

  @override
  State<BiometricScreen> createState() => _BiometricScreenState();
}

class _BiometricScreenState extends State<BiometricScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _triggerBiometric());
  }

  void _triggerBiometric() {
    context.read<AuthBloc>().add(AuthBiometricLoginRequested(widget.user));
  }

  void _usePassword() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AuthLogo(),
                  SizedBox(height: 16.h),
                  AuthHeader(
                    title: 'Welcome back',
                    subtitle: widget.user.name.isNotEmpty ? widget.user.name : widget.user.email,
                  ),
                  SizedBox(height: 40.h),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) => BiometricPromptButton(
                      onTap: _triggerBiometric,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  BiometricUsePasswordLink(onTap: _usePassword),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
