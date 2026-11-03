import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/features/student/presentation/views/student_detail_screen.dart';
import 'package:admitly/features/student/presentation/widgets/student_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<StudentBloc, StudentState>(
      builder: (context, state) {
        final students =
            state is StudentLoaded ? state.students : <StudentEntity>[];

        final total = students.length;
        final pending = students
            .where((s) => s.status == ApplicationStatus.applicationCreated)
            .length;
        final feePaid =
            students.where((s) => s.status == ApplicationStatus.feePaid).length;
        final slotBooked = students
            .where((s) => s.status == ApplicationStatus.slotBooked)
            .length;
        final examDone = students
            .where((s) => s.status == ApplicationStatus.examCompleted)
            .length;
        final admitted = students
            .where((s) => s.status == ApplicationStatus.admissionCompleted)
            .length;

        final recent = [...students]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentShown = recent.take(5).toList();

        return RefreshIndicator(
          onRefresh: () async => context
              .read<StudentBloc>()
              .add(const StudentAllLoadRequested()),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
            children: [
              _Header(colors: colors),
              SizedBox(height: 20.h),
              if (state is StudentLoading)
                Center(
                    child: Padding(
                  padding: EdgeInsets.all(32.h),
                  child: CircularProgressIndicator(color: colors.primary),
                ))
              else ...[
                _StatsGrid(
                  colors: colors,
                  stats: [
                    _Stat('Total', total, colors.primary),
                    _Stat('Pending', pending, colors.orange),
                    _Stat('Fee Paid', feePaid, colors.green),
                    _Stat('Slot Booked', slotBooked, colors.blue),
                    _Stat('Exam Done', examDone, colors.orange),
                    _Stat('Admitted', admitted, colors.green),
                  ],
                ),
                SizedBox(height: 24.h),
                Text(
                  'Recent Applications',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                SizedBox(height: 10.h),
                if (recentShown.isEmpty)
                  _EmptyState(colors: colors)
                else
                  ...recentShown.map(
                    (s) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: StudentCard(
                          student: s, onTap: () => _openDetail(s)),
                    ),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              DateFormat('EEEE, dd MMMM').format(DateTime.now()),
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 13, color: colors.grey),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'Admin',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.color);
  final String label;
  final int value;
  final Color color;
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.colors, required this.stats});
  final AppColors colors;
  final List<_Stat> stats;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 1.2,
      children: stats.map((s) => _StatCard(stat: s, colors: colors)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat, required this.colors});
  final _Stat stat;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: stat.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: stat.color.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${stat.value}',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: stat.color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            stat.label,
            style: AppTextStyles.plusJakartaSans(
                fontSize: 10, color: colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 40.w, color: colors.grey),
          SizedBox(height: 10.h),
          Text(
            'No applications yet',
            style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.text),
          ),
        ],
      ),
    );
  }
}
