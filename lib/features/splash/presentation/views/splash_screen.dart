import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  bool _authDone = false;
  bool _minDelayDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
    context.read<AuthBloc>().add(const AuthCheckRequested());

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!mounted) return;
      _minDelayDone = true;
      _tryNavigate();
    });
  }

  void _onAuthState(AuthState state) {
    if (state is AuthAuthenticated ||
        state is AuthUnauthenticated ||
        state is AuthPendingVerification ||
        state is AuthBiometricSetupAvailable ||
        state is AuthBiometricRequired) {
      _authDone = true;
      _tryNavigate();
    }
  }

  void _tryNavigate() {
    if (!_authDone || !_minDelayDone) return;
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _onAuthState(state),
      child: Scaffold(
        backgroundColor: colors.white,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    colors.isDark
                        ? 'assets/logo/logo_light.png'
                        : 'assets/logo/logo_dark.png',
                    width: 100.w,
                    height: 100.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'admitly',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'School Admission Management',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      color: colors.grey,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
