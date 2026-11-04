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
            child: Text(
              'Cancel',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Log Out',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.red,
              ),
            ),
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
    final initials = widget.user.name.isNotEmpty
        ? widget.user.name.trim().split(' ').map((w) => w[0]).take(2).join().toUpperCase()
        : '?';

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 40.h),
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initials,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.user.name,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                widget.user.email,
                style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  widget.user.role == UserRole.parent ? 'Parent' : 'Admission Team',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 28.h),
        if (widget.user.role != UserRole.parent) ...[
          _SectionCard(
            colors: colors,
            children: [
              _ActionTile(
                icon: Icons.receipt_long_outlined,
                label: 'Payment History',
                color: colors.text,
                colors: colors,
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
        _SectionCard(
          colors: colors,
          children: [
            if (_biometricAvailable)
              _ToggleTile(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric Login',
                subtitle: 'Use fingerprint or face to log in',
                value: _biometricEnabled,
                onChanged: _toggleBiometric,
                colors: colors,
              ),
            if (_biometricAvailable) Divider(color: colors.border, height: 1),
            _ActionTile(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              color: colors.red,
              colors: colors,
              onTap: () => _confirmLogout(context),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.colors, required this.children});
  final AppColors colors;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(children: children),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Icon(icon, size: 22.w, color: colors.primary),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
                Text(subtitle,
                    style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey)),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeThumbColor: colors.primary),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.colors,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final AppColors colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Icon(icon, size: 22.w, color: color),
            SizedBox(width: 14.w),
            Text(label,
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
      ),
    );
  }
}
