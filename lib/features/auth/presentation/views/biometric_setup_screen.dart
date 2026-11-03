import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:admitly/features/auth/presentation/widgets/auth_logo.dart';
import 'package:admitly/features/auth/presentation/widgets/biometric_setup_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BiometricSetupScreen extends StatelessWidget {
  const BiometricSetupScreen({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AuthLogo(),
                SizedBox(height: 40.h),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) => BiometricSetupCard(
                    isLoading: state is AuthLoading,
                    onEnable: () => context.read<AuthBloc>().add(
                          AuthBiometricSetupRequested(user: user, enable: true),
                        ),
                    onSkip: () => context.read<AuthBloc>().add(
                          AuthBiometricSetupRequested(user: user, enable: false),
                        ),
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
