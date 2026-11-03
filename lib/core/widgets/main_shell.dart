import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/admin/presentation/views/admin_applications_screen.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/views/exam_slots_screen.dart';
import 'package:admitly/features/exam_slot/presentation/widgets/create_slot_sheet.dart';
import 'package:admitly/features/home/presentation/views/admin_dashboard_screen.dart';
import 'package:admitly/features/home/presentation/views/parent_home_screen.dart';
import 'package:admitly/features/profile/presentation/views/profile_screen.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/views/student_list_screen.dart';
import 'package:admitly/features/student/presentation/widgets/create_student_sheet.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});
  final UserEntity user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  bool get _isParent => widget.user.role == UserRole.parent;

  List<_ShellTab> get _tabs =>
      _isParent ? _parentTabs() : _admissionTabs();

  List<_ShellTab> _parentTabs() => [
        _ShellTab(
          title: 'Home',
          label: 'Home',
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          page: ParentHomeScreen(
            user: widget.user,
            onViewAll: () => setState(() => _currentIndex = 1),
          ),
        ),
        _ShellTab(
          title: 'My Students',
          label: 'Students',
          icon: Icons.school_outlined,
          activeIcon: Icons.school_rounded,
          page: StudentListScreen(user: widget.user),
        ),
        _ShellTab(
          title: 'Profile',
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          page: ProfileScreen(user: widget.user),
        ),
      ];

  List<_ShellTab> _admissionTabs() => [
        _ShellTab(
          title: 'Dashboard',
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          page: AdminDashboardScreen(user: widget.user),
        ),
        _ShellTab(
          title: 'Applications',
          label: 'Applications',
          icon: Icons.folder_outlined,
          activeIcon: Icons.folder_rounded,
          page: AdminApplicationsScreen(user: widget.user),
        ),
        const _ShellTab(
          title: 'Exam Slots',
          label: 'Exam Slots',
          icon: Icons.calendar_month_outlined,
          activeIcon: Icons.calendar_month_rounded,
          page: ExamSlotsScreen(),
        ),
        _ShellTab(
          title: 'Profile',
          label: 'Profile',
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          page: ProfileScreen(user: widget.user),
        ),
      ];

  Widget? _buildFab() {
    if (_isParent && (_currentIndex == 0 || _currentIndex == 1)) {
      return FloatingActionButton.extended(
        heroTag: 'fab_add_student',
        onPressed: () => showCreateStudentSheet(
          context,
          parentId: widget.user.uid,
        ),
        backgroundColor: context.colors.primary,
        label: Text(
          'Add Student',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        icon: const Icon(Icons.add, color: Colors.white),
      );
    }
    if (!_isParent && _currentIndex == 2) {
      return FloatingActionButton.extended(
        heroTag: 'fab_create_slot',
        onPressed: () => showCreateSlotSheet(context),
        backgroundColor: context.colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Create Slot',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tabs = _tabs;

    return MultiBlocProvider(
      providers: [
        BlocProvider<StudentBloc>(
          create: (_) => sl<StudentBloc>(),
        ),
        BlocProvider<ExamSlotBloc>(
          create: (_) => sl<ExamSlotBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: colors.background,
            appBar: AppBar(
              backgroundColor: colors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              title: Text(
                tabs[_currentIndex].title,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: colors.text,
                ),
              ),
            ),
            body: IndexedStack(
              index: _currentIndex,
              children: tabs.map((t) => t.page).toList(),
            ),
            floatingActionButton: _buildFab(),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
              backgroundColor: colors.surface,
              surfaceTintColor: Colors.transparent,
              indicatorColor: colors.primary.withValues(alpha: 0.12),
              destinations: tabs
                  .map((t) => NavigationDestination(
                        icon: Icon(t.icon, color: colors.grey),
                        selectedIcon: Icon(t.activeIcon, color: colors.primary),
                        label: t.label,
                      ))
                  .toList(),
            ),
          );
        },
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.title,
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
  final String title;
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
}
