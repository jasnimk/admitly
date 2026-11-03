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

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<AdminApplicationsScreen> createState() =>
      _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  ApplicationStatus? _filter;

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
        final all =
            state is StudentLoaded ? state.students : <StudentEntity>[];
        final filtered = _filter == null
            ? all
            : all.where((s) => s.status == _filter).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterBar(
              colors: colors,
              selected: _filter,
              onSelect: (f) => setState(() => _filter = f),
              counts: {
                null: all.length,
                ApplicationStatus.applicationCreated: all
                    .where((s) =>
                        s.status == ApplicationStatus.applicationCreated)
                    .length,
                ApplicationStatus.feePaid: all
                    .where((s) => s.status == ApplicationStatus.feePaid)
                    .length,
                ApplicationStatus.slotBooked: all
                    .where((s) => s.status == ApplicationStatus.slotBooked)
                    .length,
                ApplicationStatus.examCompleted: all
                    .where(
                        (s) => s.status == ApplicationStatus.examCompleted)
                    .length,
                ApplicationStatus.admissionCompleted: all
                    .where((s) =>
                        s.status == ApplicationStatus.admissionCompleted)
                    .length,
              },
            ),
            Expanded(
              child: state is StudentLoading
                  ? Center(
                      child: CircularProgressIndicator(color: colors.primary))
                  : filtered.isEmpty
                      ? _Empty(colors: colors)
                      : RefreshIndicator(
                          onRefresh: () async => context
                              .read<StudentBloc>()
                              .add(const StudentAllLoadRequested()),
                          child: ListView.separated(
                            padding: EdgeInsets.fromLTRB(
                                16.w, 12.h, 16.w, 100.h),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                SizedBox(height: 10.h),
                            itemBuilder: (_, i) => StudentCard(
                              student: filtered[i],
                              onTap: () => _openDetail(filtered[i]),
                            ),
                          ),
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.colors,
    required this.selected,
    required this.onSelect,
    required this.counts,
  });
  final AppColors colors;
  final ApplicationStatus? selected;
  final ValueChanged<ApplicationStatus?> onSelect;
  final Map<ApplicationStatus?, int> counts;

  static const _chips = <(ApplicationStatus?, String)>[
    (null, 'All'),
    (ApplicationStatus.applicationCreated, 'Pending'),
    (ApplicationStatus.feePaid, 'Fee Paid'),
    (ApplicationStatus.slotBooked, 'Slot Booked'),
    (ApplicationStatus.examCompleted, 'Exam Done'),
    (ApplicationStatus.admissionCompleted, 'Admitted'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: _chips.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (_, i) {
          final (status, label) = _chips[i];
          final active = selected == status;
          final count = counts[status] ?? 0;
          return GestureDetector(
            onTap: () => onSelect(status),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active
                    ? colors.primary
                    : colors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                    color: active
                        ? colors.primary
                        : colors.primary.withValues(alpha: 0.12)),
              ),
              child: Text(
                '$label ($count)',
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : colors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.folder_open_outlined, size: 48.w, color: colors.grey),
          SizedBox(height: 12.h),
          Text(
            'No students found',
            style: AppTextStyles.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: colors.text),
          ),
        ],
      ),
    );
  }
}
