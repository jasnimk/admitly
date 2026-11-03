import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) => AppButton(
        label: 'Continue with Google',
        variant: AppButtonVariant.outlined,
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
