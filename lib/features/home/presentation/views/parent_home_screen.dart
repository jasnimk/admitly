import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_section_header.dart';
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

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({
    super.key,
    required this.user,
    required this.onViewAll,
  });
  final UserEntity user;
  final VoidCallback onViewAll;

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
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
    context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final greeting = _greeting();

    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid));
        }
      },
      builder: (context, state) {
        final students = state is StudentLoaded ? state.students : <StudentEntity>[];
        final pending = students
            .where((s) => s.status == ApplicationStatus.applicationCreated)
            .toList();
        final recent = [...students]
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final recentShown = recent.take(3).toList();

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<StudentBloc>().add(StudentLoadRequested(widget.user.uid)),
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
            children: [
              SizedBox(height: 16.h),
              _GreetingHeader(
                  greeting: greeting, user: widget.user, colors: colors),
              SizedBox(height: 20.h),
              _StatsRow(students: students, colors: colors),
              SizedBox(height: 24.h),
              if (pending.isNotEmpty) ...[
                AppSectionHeader(
                  title: 'Pending Actions',
                  subtitle: '${pending.length} application${pending.length > 1 ? 's' : ''} awaiting fee payment',
                ),
                SizedBox(height: 10.h),
                ...pending.take(2).map((s) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: StudentCard(
                          student: s, onTap: () => _openDetail(s)),
                    )),
                if (pending.length > 2) ...[
                  SizedBox(height: 4.h),
                  _ViewAllButton(label: 'View all pending', onTap: widget.onViewAll, colors: colors),
                ],
                SizedBox(height: 24.h),
              ],
              AppSectionHeader(
                title: 'Recent Applications',
                actionLabel: students.length > 3 ? 'View all' : null,
                onAction: students.length > 3 ? widget.onViewAll : null,
              ),
              SizedBox(height: 10.h),
              if (state is StudentLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.h),
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                )
              else if (recentShown.isEmpty)
                _EmptyStudents(colors: colors)
              else
                ...recentShown.map((s) => Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: StudentCard(
                          student: s, onTap: () => _openDetail(s)),
                    )),
            ],
          ),
        );
      },
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader(
      {required this.greeting, required this.user, required this.colors});
  final String greeting;
  final UserEntity user;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final firstName = user.name.split(' ').first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting, $firstName!',
          style: AppTextStyles.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.text,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          DateFormat('EEEE, dd MMMM').format(DateTime.now()),
          style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.students, required this.colors});
  final List<StudentEntity> students;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final total = students.length;
    final inProgress = students
        .where((s) =>
            s.status != ApplicationStatus.admissionCompleted &&
            s.status != ApplicationStatus.applicationCreated)
        .length;
    final admitted =
        students.where((s) => s.status == ApplicationStatus.admissionCompleted).length;

    return Row(
      children: [
        _StatCard(label: 'Total', value: '$total', color: colors.primary, colors: colors),
        SizedBox(width: 10.w),
        _StatCard(label: 'In Progress', value: '$inProgress', color: colors.accent, colors: colors),
        SizedBox(width: 10.w),
        _StatCard(label: 'Admitted', value: '$admitted', color: colors.primary, colors: colors),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.label,
      required this.value,
      required this.color,
      required this.colors});
  final String label;
  final String value;
  final Color color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            SizedBox(height: 2.h),
            Text(label,
                style: AppTextStyles.plusJakartaSans(fontSize: 11, color: colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton(
      {required this.label, required this.onTap, required this.colors});
  final String label;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(label,
          style: AppTextStyles.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: colors.primary)),
    );
  }
}

class _EmptyStudents extends StatelessWidget {
  const _EmptyStudents({required this.colors});
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
          Icon(Icons.school_outlined, size: 40.w, color: colors.grey),
          SizedBox(height: 10.h),
          Text('No students yet',
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 14, fontWeight: FontWeight.w600, color: colors.text)),
          SizedBox(height: 4.h),
          Text('Tap + to add your first student',
              style:
                  AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey)),
        ],
      ),
    );
  }
}
