import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/services/biometric_service.dart';
import 'package:admitly/core/services/secure_storage_service.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_bloc.dart';
import 'package:admitly/features/payment/presentation/bloc/payment_event.dart';
import 'package:admitly/features/payment/presentation/views/payment_history_screen.dart';
import 'package:admitly/features/profile/presentation/widgets/profile_action_tile.dart';
import 'package:admitly/features/profile/presentation/widgets/profile_header.dart';
import 'package:admitly/features/profile/presentation/widgets/profile_section_card.dart';
import 'package:admitly/features/profile/presentation/widgets/profile_toggle_tile.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricEnabled = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadBiometricState();
  }

  Future<void> _loadBiometricState() async {
    final available = await sl<BiometricService>().isAvailable();
    final enabled = await sl<SecureStorageService>().isBiometricEnabled();
    if (!mounted) return;
    setState(() {
      _biometricAvailable = available;
      _biometricEnabled = enabled;
    });
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Log Out?',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        content: Text(
          'You will need to sign in again to access the app.',
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: colors.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Log Out',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // ignore: use_build_context_synchronously
      context.read<AuthBloc>().add(const AuthLogoutRequested());
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    context.read<AuthBloc>().add(
          AuthBiometricSetupRequested(user: widget.user, enable: value),
        );
    setState(() => _biometricEnabled = value);
    AppSnackBar.show(
      context,
      value ? 'Biometric login enabled' : 'Biometric login disabled',
      type: SnackBarType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
      children: [
        ProfileHeader(user: widget.user),
        SizedBox(height: 28.h),
        if (widget.user.role != UserRole.parent) ...[
          ProfileSectionCard(
            children: [
              ProfileActionTile(
                icon: Icons.receipt_long_outlined,
                label: 'Payment History',
                color: colors.text,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => sl<PaymentBloc>()
                        ..add(const PaymentLoadAllRequested()),
                      child: Scaffold(
                        backgroundColor: colors.background,
                        appBar: AppBar(
                          backgroundColor: colors.background,
                          elevation: 0,
                          leading: IconButton(
                            icon: Icon(Icons.arrow_back_ios_new_rounded,
                                size: 18.w, color: colors.text),
                            onPressed: () => Navigator.pop(context),
                          ),
                          title: Text(
                            'Payment History',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                        ),
                        body: const PaymentHistoryScreen(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
        ProfileSectionCard(
          children: [
            if (_biometricAvailable)
              ProfileToggleTile(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric Login',
                subtitle: 'Use fingerprint or face to log in',
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
              ),
            if (_biometricAvailable) Divider(color: colors.border, height: 1),
            ProfileActionTile(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: colors.red,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ],
    );
  }
}
