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

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key, required this.user});
  final UserEntity user;

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen>
    with SingleTickerProviderStateMixin {
  static const _tabs = <(ApplicationStatus?, String)>[
    (null, 'All'),
    (ApplicationStatus.applicationCreated, 'Pending'),
    (ApplicationStatus.feePaid, 'Fee Paid'),
    (ApplicationStatus.feeSkipped, 'Fee Skipped'),
    (ApplicationStatus.slotBooked, 'Slot Booked'),
    (ApplicationStatus.examCompleted, 'Exam Done'),
    (ApplicationStatus.admissionCompleted, 'Admitted'),
  ];

  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
    _tabCtrl.addListener(() => setState(() {}));
    context.read<StudentBloc>().add(const StudentAllLoadRequested());
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
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

    return BlocConsumer<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          context.read<StudentBloc>().add(const StudentAllLoadRequested());
        }
      },
      builder: (context, state) {
        final all = state is StudentLoaded ? state.students : <StudentEntity>[];
        final activeStatus = _tabs[_tabCtrl.index].$1;
        final filtered = activeStatus == null
            ? all
            : all.where((s) => s.status == activeStatus).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FilterTabBar(
              controller: _tabCtrl,
              tabs: _tabs,
              all: all,
              colors: colors,
            ),
            Divider(height: 1, color: colors.border),
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
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) => SizedBox(height: 10.h),
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

class _FilterTabBar extends StatelessWidget {
  const _FilterTabBar({
    required this.controller,
    required this.tabs,
    required this.all,
    required this.colors,
  });
  final TabController controller;
  final List<(ApplicationStatus?, String)> tabs;
  final List<StudentEntity> all;
  final AppColors colors;

  int _count(ApplicationStatus? status) => status == null
      ? all.length
      : all.where((s) => s.status == status).length;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.background,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: colors.primary, width: 1.5),
        ),
        child: TabBar(
          controller: controller,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicator: BoxDecoration(
            color: colors.canvas,
            borderRadius: BorderRadius.circular(20.r),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(3.r),
          labelColor: colors.primary,
          unselectedLabelColor: colors.mist,
          labelStyle: AppTextStyles.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: AppTextStyles.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          tabs: tabs
              .map((t) => Tab(text: '${t.$2} (${_count(t.$1)})'))
              .toList(),
        ),
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
