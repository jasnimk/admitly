import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/home/presentation/views/home_screen.dart';
import 'package:admitly/features/student/presentation/views/student_list_screen.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/domain/usecases/create_student_usecase.dart';
import 'package:admitly/features/student/domain/usecases/get_students_usecase.dart';
import 'package:admitly/features/student/domain/usecases/update_student_usecase.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.user});
  final UserEntity user;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<_ShellTab> get _tabs => widget.user.role == UserRole.parent
      ? _parentTabs
      : _admissionTabs;

  late final List<_ShellTab> _parentTabs = [
    _ShellTab(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      page: HomeScreen(user: widget.user),
    ),
    _ShellTab(
      label: 'Students',
      icon: Icons.school_outlined,
      activeIcon: Icons.school_rounded,
      page: BlocProvider(
        create: (_) => StudentBloc(
          createStudentUseCase: sl<CreateStudentUseCase>(),
          getStudentsByParentUseCase: sl<GetStudentsByParentUseCase>(),
          getAllStudentsUseCase: sl<GetAllStudentsUseCase>(),
          updateStudentUseCase: sl<UpdateStudentUseCase>(),
        ),
        child: StudentListScreen(user: widget.user),
      ),
    ),
  ];

  late final List<_ShellTab> _admissionTabs = [
    _ShellTab(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      page: HomeScreen(user: widget.user),
    ),
    _ShellTab(
      label: 'Applications',
      icon: Icons.folder_outlined,
      activeIcon: Icons.folder_rounded,
      page: BlocProvider(
        create: (_) => StudentBloc(
          createStudentUseCase: sl<CreateStudentUseCase>(),
          getStudentsByParentUseCase: sl<GetStudentsByParentUseCase>(),
          getAllStudentsUseCase: sl<GetAllStudentsUseCase>(),
          updateStudentUseCase: sl<UpdateStudentUseCase>(),
        ),
        child: const _PlaceholderPage(label: 'Student Applications'),
      ),
    ),
    _ShellTab(
      label: 'Exam Slots',
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      page: const _PlaceholderPage(label: 'Exam Slot Management'),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs.map((t) => t.page).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colors.primary.withValues(alpha: 0.12),
        destinations: _tabs
            .map((t) => NavigationDestination(
                  icon: Icon(t.icon, color: colors.grey),
                  selectedIcon: Icon(t.activeIcon, color: colors.primary),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.page,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final Widget page;
}

class _PlaceholderPage extends StatelessWidget {
  const _PlaceholderPage({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Text(label,
            style: TextStyle(color: colors.grey, fontSize: 16)),
      ),
    );
  }
}
