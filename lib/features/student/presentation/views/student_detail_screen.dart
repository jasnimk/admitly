import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/exam_slot/presentation/widgets/book_slot_sheet.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/features/student/presentation/widgets/create_student_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/registration_fee_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({
    super.key,
    required this.student,
    required this.viewer,
  });
  final StudentEntity student;
  final UserEntity viewer;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late StudentEntity _student;

  @override
  void initState() {
    super.initState();
    _student = widget.student;
  }

  void _onEdit() async {
    await showCreateStudentSheet(
      context,
      parentId: _student.parentId,
      existing: _student,
    );
    if (!mounted) return;
    context.read<StudentBloc>().add(StudentLoadRequested(_student.parentId));
  }

  void _onFeeAction() async {
    await showRegistrationFeeSheet(context, student: _student);
    if (!mounted) return;
    context.read<StudentBloc>().add(StudentLoadRequested(_student.parentId));
  }

  void _onBookSlot() async {
    final booked = await showBookSlotSheet(context, studentId: _student.id);
    if (!mounted) return;
    if (booked) {
      context.read<StudentBloc>().add(StudentLoadRequested(_student.parentId));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isParent = widget.viewer.role == UserRole.parent;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentLoaded) {
          final updated = state.students
              .where((s) => s.id == _student.id)
              .firstOrNull;
          if (updated != null) setState(() => _student = updated);
        }
      },
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
            'Application',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
          actions: [
            if (isParent && _student.isEditable)
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20.w, color: colors.text),
                onPressed: _onEdit,
              ),
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
          children: [
            _HeaderCard(student: _student, colors: colors),
            SizedBox(height: 16.h),
            _StatusStepper(status: _student.status, colors: colors),
            SizedBox(height: 16.h),
            _DetailsCard(student: _student, colors: colors),
            if (_student.examSlotId != null) ...[
              SizedBox(height: 16.h),
              _SlotInfoCard(slotId: _student.examSlotId!, colors: colors),
            ],
            if (_student.examScore != null) ...[
              SizedBox(height: 16.h),
              _ExamResultCard(
                  score: _student.examScore!,
                  course: _student.assignedCourse,
                  colors: colors),
            ],
            SizedBox(height: 24.h),
            if (isParent) _parentActions(colors),
            if (!isParent) _adminActions(colors),
          ],
        ),
      ),
    );
  }

  Future<void> _onEnterScore() async {
    final score = await _showScoreDialog();
    if (score == null || !mounted) return;
    context.read<StudentBloc>().add(
          StudentUpdateRequested(
            _student.copyWith(
              examScore: score,
              status: ApplicationStatus.examCompleted,
            ),
          ),
        );
  }

  Future<int?> _showScoreDialog() async {
    final ctrl = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Enter Exam Score',
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: colors.text)),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
            decoration: InputDecoration(
              hintText: 'Score out of 100',
              hintStyle: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
              suffixText: '/ 100',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, color: colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text.trim());
                if (v != null && v >= 0 && v <= 100) {
                  Navigator.pop(ctx, v);
                }
              },
              child: Text('Save',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _onAssignCourse() async {
    final course = await _showCourseDialog();
    if (course == null || !mounted) return;
    context.read<StudentBloc>().add(
          StudentUpdateRequested(
            _student.copyWith(assignedCourse: course),
          ),
        );
  }

  Future<String?> _showCourseDialog() async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) {
        final colors = ctx.colors;
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text('Assign Course',
              style: AppTextStyles.plusJakartaSans(
                  fontSize: 17, fontWeight: FontWeight.w700, color: colors.text)),
          content: TextField(
            controller: ctrl,
            autofocus: true,
            style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
            decoration: InputDecoration(
              hintText: 'e.g. Grade 6 — Science',
              hintStyle: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, color: colors.grey)),
            ),
            TextButton(
              onPressed: () {
                final v = ctrl.text.trim();
                if (v.isNotEmpty) Navigator.pop(ctx, v);
              },
              child: Text('Assign',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: colors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _onCompleteAdmission() {
    context.read<StudentBloc>().add(
          StudentUpdateRequested(
            _student.copyWith(status: ApplicationStatus.admissionCompleted),
          ),
        );
  }

  Widget _adminActions(AppColors colors) {
    return switch (_student.status) {
      ApplicationStatus.slotBooked => _ActionButton(
          label: 'Enter Exam Score',
          icon: Icons.quiz_outlined,
          color: colors.orange,
          onTap: _onEnterScore,
        ),
      ApplicationStatus.examCompleted when _student.assignedCourse == null =>
        _ActionButton(
          label: 'Assign Course',
          icon: Icons.book_outlined,
          color: colors.blue,
          onTap: _onAssignCourse,
        ),
      ApplicationStatus.examCompleted => _ActionButton(
          label: 'Complete Admission',
          icon: Icons.check_circle_outline_rounded,
          color: colors.green,
          onTap: _onCompleteAdmission,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _parentActions(AppColors colors) {
    return switch (_student.status) {
      ApplicationStatus.applicationCreated => _ActionButton(
          label: 'Pay Registration Fee',
          icon: Icons.payment_outlined,
          color: colors.primary,
          onTap: _onFeeAction,
        ),
      ApplicationStatus.feePaid ||
      ApplicationStatus.feeSkipped =>
        _ActionButton(
          label: 'Book Exam Slot',
          icon: Icons.calendar_month_outlined,
          color: colors.blue,
          onTap: _onBookSlot,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.student, required this.colors});
  final StudentEntity student;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, size: 28.w, color: colors.primary),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: colors.text,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  student.applyingGrade,
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, color: colors.grey),
                ),
              ],
            ),
          ),
          _StatusBadge(status: student.status),
        ],
      ),
    );
  }
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.status, required this.colors});
  final ApplicationStatus status;
  final AppColors colors;

  static const _steps = [
    (ApplicationStatus.applicationCreated, 'Applied', Icons.assignment_outlined),
    (ApplicationStatus.feePaid, 'Fee', Icons.receipt_outlined),
    (ApplicationStatus.slotBooked, 'Slot Booked', Icons.event_outlined),
    (ApplicationStatus.examCompleted, 'Exam', Icons.quiz_outlined),
    (ApplicationStatus.admissionCompleted, 'Admitted', Icons.school_outlined),
  ];

  int get _currentIndex {
    if (status == ApplicationStatus.feeSkipped) return 1;
    return _steps.indexWhere((s) => s.$1 == status);
  }

  @override
  Widget build(BuildContext context) {
    final current = _currentIndex;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Progress',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.grey,
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            children: List.generate(_steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIndex = i ~/ 2;
                final done = stepIndex < current;
                return Expanded(
                  child: Container(
                    height: 2.h,
                    color: done ? colors.primary : colors.border,
                  ),
                );
              }
              final stepIndex = i ~/ 2;
              final done = stepIndex < current;
              final active = stepIndex == current;
              final (_, label, icon) = _steps[stepIndex];
              return Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done || active
                          ? colors.primary
                          : colors.background,
                      border: Border.all(
                        color: done || active ? colors.primary : colors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check_rounded : icon,
                      size: 14.w,
                      color: done || active ? Colors.white : colors.grey,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  SizedBox(
                    width: 52.w,
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: active
                            ? FontWeight.w700
                            : FontWeight.w400,
                        color: active ? colors.primary : colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.student, required this.colors});
  final StudentEntity student;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Student Details',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.grey,
            ),
          ),
          SizedBox(height: 12.h),
          _detailRow('Date of Birth',
              DateFormat('dd MMM yyyy').format(student.dateOfBirth), colors),
          _detailRow('Gender',
              student.gender.name[0].toUpperCase() +
                  student.gender.name.substring(1),
              colors),
          _detailRow('Previous School', student.previousSchool, colors),
          _detailRow('Applying For', student.applyingGrade, colors),
          _detailRow(
            'Applied On',
            DateFormat('dd MMM yyyy').format(student.createdAt),
            colors,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, AppColors colors,
      {bool isLast = false}) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Text(label,
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, color: colors.grey)),
              const Spacer(),
              Text(value,
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  )),
            ],
          ),
        ),
        if (!isLast) Divider(color: colors.border, height: 1),
      ],
    );
  }
}

class _SlotInfoCard extends StatelessWidget {
  const _SlotInfoCard({required this.slotId, required this.colors});
  final String slotId;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.blue.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: colors.blue, size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Exam Slot Booked',
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colors.blue,
                    )),
                Text('Slot ID: $slotId',
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 11, color: colors.blue),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExamResultCard extends StatelessWidget {
  const _ExamResultCard(
      {required this.score, required this.course, required this.colors});
  final int score;
  final String? course;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final passed = score >= 40;
    final color = passed ? colors.green : colors.red;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.emoji_events_outlined : Icons.cancel_outlined,
            color: color,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Exam Score: $score / 100',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  )),
              if (course != null)
                Text('Assigned: $course',
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 12, color: colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.w, color: color),
            ),
            SizedBox(width: 14.w),
            Text(
              label,
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.w, color: color),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = switch (status) {
      ApplicationStatus.applicationCreated => colors.blue,
      ApplicationStatus.feePaid => colors.green,
      ApplicationStatus.feeSkipped => colors.orange,
      ApplicationStatus.slotBooked => colors.primary,
      ApplicationStatus.examCompleted => colors.orange,
      ApplicationStatus.admissionCompleted => colors.green,
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        status.label,
        style: AppTextStyles.plusJakartaSans(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
