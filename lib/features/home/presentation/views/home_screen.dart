import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:admitly/features/auth/presentation/bloc/auth_event.dart';
import 'package:admitly/features/home/presentation/widgets/home_app_bar.dart';
import 'package:admitly/features/home/presentation/widgets/home_quick_action_card.dart';
import 'package:admitly/features/home/presentation/widgets/home_welcome_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.user});

  final UserEntity user;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isAdmin = user.role == UserRole.admissionTeam;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: HomeAppBar(
        onLogout: () => context.read<AuthBloc>().add(const AuthLogoutRequested()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeWelcomeBanner(user: user),
            SizedBox(height: 28.h),
            Text(
              isAdmin ? 'Manage' : 'Quick Actions',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            SizedBox(height: 12.h),
            if (isAdmin) ..._adminActions(context) else ..._parentActions(context),
          ],
        ),
      ),
    );
  }

  List<Widget> _parentActions(BuildContext context) => [
        HomeQuickActionCard(
          icon: Icons.description_outlined,
          title: 'My Applications',
          subtitle: 'View and track your applications',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        HomeQuickActionCard(
          icon: Icons.add_circle_outline_rounded,
          title: 'New Application',
          subtitle: 'Apply for school admission',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        HomeQuickActionCard(
          icon: Icons.calendar_month_outlined,
          title: 'Exam Slots',
          subtitle: 'Book or view your exam slot',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        HomeQuickActionCard(
          icon: Icons.receipt_long_outlined,
          title: 'Fee Payment',
          subtitle: 'Registration fee status',
          onTap: () {},
        ),
      ];

  List<Widget> _adminActions(BuildContext context) => [
        HomeQuickActionCard(
          icon: Icons.folder_open_outlined,
          title: 'All Applications',
          subtitle: 'Review and manage submissions',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        HomeQuickActionCard(
          icon: Icons.event_available_outlined,
          title: 'Exam Slot Management',
          subtitle: 'Configure available exam slots',
          onTap: () {},
        ),
        SizedBox(height: 12.h),
        HomeQuickActionCard(
          icon: Icons.grading_outlined,
          title: 'Results & Courses',
          subtitle: 'Publish results and assign courses',
          onTap: () {},
        ),
      ];
}
