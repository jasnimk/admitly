import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/widgets/app_loader.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/home/presentation/widgets/dashboard_admitted_card.dart';
import 'package:admitly/features/home/presentation/widgets/dashboard_hero_banner.dart';
import 'package:admitly/features/home/presentation/widgets/dashboard_info_banner.dart';
import 'package:admitly/features/home/presentation/widgets/dashboard_recent_section.dart';
import 'package:admitly/features/home/presentation/widgets/dashboard_stats_grid.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/features/student/presentation/views/student_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(const StudentAllLoadRequested());
  }

  Future<void> _openDetail(StudentEntity student) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<StudentBloc>(),
          child: StudentDetailScreen(student: student, viewer: widget.user),
        ),
      ),
    );
    if (!mounted) return;
    context.read<StudentBloc>().add(const StudentAllLoadRequested());
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          context.read<StudentBloc>().add(const StudentAllLoadRequested());
        }
      },
      builder: (context, state) {
        final students =
            state is StudentLoaded ? state.students : <StudentEntity>[];
        final stats = _DashboardStats.from(students);
        final recent = ([...students]
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
            .take(5)
            .toList();

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<StudentBloc>().add(const StudentAllLoadRequested()),
          child: ListView(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            children: [
              DashboardHeroBanner(
                greeting: _greeting,
                name: widget.user.name.split(' ').first,
                total: stats.total,
              ),
              SizedBox(height: 20.h),
              if (state is StudentLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: AppLoader(),
                )
              else ...[
                DashboardStatsGrid(
                  pending: stats.pending,
                  feePaid: stats.feePaid,
                  slotBooked: stats.slotBooked,
                  examDone: stats.examDone,
                ),
                SizedBox(height: 12.h),
                DashboardAdmittedCard(admitted: stats.admitted, total: stats.total),
                if (stats.feeSkipped > 0) ...[
                  SizedBox(height: 8.h),
                  DashboardInfoBanner(
                    icon: Icons.info_outline_rounded,
                    message:
                        '${stats.feeSkipped} student${stats.feeSkipped > 1 ? 's' : ''} skipped fee payment',
                    color: colors.grey,
                  ),
                ],
                SizedBox(height: 24.h),
                DashboardRecentSection(students: recent, onTap: _openDetail),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _DashboardStats {
  const _DashboardStats({
    required this.total,
    required this.pending,
    required this.feePaid,
    required this.slotBooked,
    required this.examDone,
    required this.admitted,
    required this.feeSkipped,
  });

  factory _DashboardStats.from(List<StudentEntity> students) => _DashboardStats(
        total: students.length,
        pending: students
            .where((s) => s.status == ApplicationStatus.applicationCreated)
            .length,
        feePaid: students
            .where((s) => s.status == ApplicationStatus.feePaid)
            .length,
        slotBooked: students
            .where((s) => s.status == ApplicationStatus.slotBooked)
            .length,
        examDone: students
            .where((s) => s.status == ApplicationStatus.examCompleted)
            .length,
        admitted: students
            .where((s) => s.status == ApplicationStatus.admissionCompleted)
            .length,
        feeSkipped: students
            .where((s) => s.status == ApplicationStatus.feeSkipped)
            .length,
      );

  final int total;
  final int pending;
  final int feePaid;
  final int slotBooked;
  final int examDone;
  final int admitted;
  final int feeSkipped;
}
