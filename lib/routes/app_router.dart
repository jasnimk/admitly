import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_state.dart';
import 'package:admitly/features/auth/presentation/views/login_screen.dart';
import 'package:admitly/features/auth/presentation/views/register_screen.dart';
import 'package:admitly/features/splash/presentation/views/splash_screen.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => BlocProvider(
              create: (_) => sl<AuthBloc>(),
              child: const SplashScreen(),
            ));
      case '/home':
        return MaterialPageRoute(builder: (_) => const _AuthGate());
      case '/login':
        return MaterialPageRoute(builder: (_) => const _LoginWrapper());
      case '/register':
        return MaterialPageRoute(builder: (_) => const _RegisterWrapper());
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoading || state is AuthInitial) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (state is AuthAuthenticated) {
            return _homeForRole(state.user);
          }
          return const _LoginWrapper();
        },
      ),
    );
  }

  Widget _homeForRole(UserEntity user) {
    // Placeholder — will be replaced with actual dashboards in next push
    return Scaffold(
      body: Center(
        child: Text('Welcome ${user.name} — ${user.role.name}'),
      ),
    );
  }
}

class _LoginWrapper extends StatelessWidget {
  const _LoginWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: LoginScreen(
        onRegisterTap: () => Navigator.pushNamed(context, '/register'),
        onLoginSuccess: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    );
  }
}

class _RegisterWrapper extends StatelessWidget {
  const _RegisterWrapper();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: RegisterScreen(
        onLoginTap: () => Navigator.pop(context),
        onRegisterSuccess: () => Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false),
      ),
    );
  }
}
