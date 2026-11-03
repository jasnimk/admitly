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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<StudentBloc, StudentState>(
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
              _HeroBanner(
                greeting: _greeting,
                name: widget.user.name.split(' ').first,
                total: stats.total,
                colors: colors,
              ),
              SizedBox(height: 20.h),
              if (state is StudentLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: CircularProgressIndicator(color: colors.primary),
                  ),
                )
              else ...[
                _StatsGrid(stats: stats, colors: colors),
                SizedBox(height: 12.h),
                _AdmittedCard(
                    admitted: stats.admitted, total: stats.total, colors: colors),
                if (stats.feeSkipped > 0) ...[
                  SizedBox(height: 8.h),
                  _InfoBanner(
                    icon: Icons.info_outline_rounded,
                    message:
                        '${stats.feeSkipped} student${stats.feeSkipped > 1 ? 's' : ''} skipped fee payment',
                    color: colors.grey,
                    colors: colors,
                  ),
                ],
                SizedBox(height: 24.h),
                _RecentSection(
                    students: recent, onTap: _openDetail, colors: colors),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ── Dashboard stats ──────────────────────────────────────────────────────────

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

// ── Stats grid ───────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.colors});
  final _DashboardStats stats;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.hourglass_empty_rounded,
                label: 'Pending',
                value: stats.pending,
                color: colors.subtle,
                colors: colors,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.receipt_long_outlined,
                label: 'Fee Paid',
                value: stats.feePaid,
                color: colors.accent,
                colors: colors,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.event_available_outlined,
                label: 'Slot Booked',
                value: stats.slotBooked,
                color: colors.primary,
                colors: colors,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _StatCard(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Exam Done',
                value: stats.examDone,
                color: colors.subtle,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Recent section ───────────────────────────────────────────────────────────

class _RecentSection extends StatelessWidget {
  const _RecentSection({
    required this.students,
    required this.onTap,
    required this.colors,
  });
  final List<StudentEntity> students;
  final void Function(StudentEntity) onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Recent Applications',
              style: AppTextStyles.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            const Spacer(),
            if (students.isNotEmpty)
              Text(
                'Latest ${students.length}',
                style:
                    AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (students.isEmpty)
          _EmptyState(colors: colors)
        else
          ...students.map(
            (s) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: StudentCard(student: s, onTap: () => onTap(s)),
            ),
          ),
      ],
    );
  }
}

// ── Hero banner ──────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({
    required this.greeting,
    required this.name,
    required this.total,
    required this.colors,
  });
  final String greeting;
  final String name;
  final int total;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $name',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(DateTime.now()),
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    _HeroChip(
                      label: '$total total',
                      icon: Icons.people_outline_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(
              Icons.school_rounded,
              size: 28.w,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroChip extends StatelessWidget {
  const _HeroChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.w, color: Colors.white),
          SizedBox(width: 5.w),
          Text(
            label,
            style: AppTextStyles.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.w, color: color),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$value',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: colors.text,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 11,
                  color: colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Admitted highlight ───────────────────────────────────────────────────────

class _AdmittedCard extends StatelessWidget {
  const _AdmittedCard({
    required this.admitted,
    required this.total,
    required this.colors,
  });
  final int admitted;
  final int total;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? admitted / total : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.school_rounded,
                size: 18.w, color: colors.primary),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$admitted',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: colors.text,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Admitted',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 4.h,
                    backgroundColor: colors.border,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(colors.primary),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '${(pct * 100).round()}%',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: colors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info banner ──────────────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.colors,
  });
  final IconData icon;
  final String message;
  final Color color;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15.w, color: color),
          SizedBox(width: 8.w),
          Text(
            message,
            style: AppTextStyles.plusJakartaSans(
                fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(28.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined,
              size: 40.w, color: colors.grey),
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
