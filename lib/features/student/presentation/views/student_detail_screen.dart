import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/auth/domain/entities/user_entity.dart';
import 'package:admitly/features/exam_slot/presentation/widgets/book_slot_sheet.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:admitly/features/student/presentation/widgets/admin_action_row.dart';
import 'package:admitly/features/student/presentation/widgets/assign_course_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/contact_button.dart';
import 'package:admitly/features/student/presentation/widgets/create_student_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/enter_score_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/exam_result_card.dart';
import 'package:admitly/features/student/presentation/widgets/registration_fee_sheet.dart';
import 'package:admitly/features/student/presentation/widgets/slot_info_card.dart';
import 'package:admitly/features/student/presentation/widgets/student_action_button.dart';
import 'package:admitly/features/student/presentation/widgets/student_details_card.dart';
import 'package:admitly/features/student/presentation/widgets/student_header_card.dart';
import 'package:admitly/features/student/presentation/widgets/student_info_banner.dart';
import 'package:admitly/features/student/presentation/widgets/student_status_stepper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _onDelete() async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Remove Student?',
          style: AppTextStyles.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700, color: colors.text),
        ),
        content: Text(
          'This will permanently delete ${_student.name}\'s application. This cannot be undone.',
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.secondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: colors.secondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, fontWeight: FontWeight.w600, color: colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      // ignore: use_build_context_synchronously
      context.read<StudentBloc>().add(StudentDeleteRequested(_student.id));
    }
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

  Future<void> _onEnterScore() async {
    final score = await showEnterScoreSheet(
      context,
      studentName: _student.name,
      existingScore: _student.examScore,
    );
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

  Future<void> _onAssignCourse() async {
    final course = await showAssignCourseSheet(
      context,
      existingCourse: _student.assignedCourse,
    );
    if (course == null || !mounted) return;
    context.read<StudentBloc>().add(
          StudentUpdateRequested(_student.copyWith(assignedCourse: course)),
        );
  }

  void _onCompleteAdmission() {
    context.read<StudentBloc>().add(
          StudentUpdateRequested(
            _student.copyWith(status: ApplicationStatus.admissionCompleted),
          ),
        );
  }

  void _onEnablePayment() {
    context.read<StudentBloc>().add(
          StudentUpdateRequested(
            _student.copyWith(status: ApplicationStatus.applicationCreated),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isParent = widget.viewer.role == UserRole.parent;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentLoaded) {
          final updated =
              state.students.where((s) => s.id == _student.id).firstOrNull;
          if (updated != null) setState(() => _student = updated);
        }
        if (state is StudentActionSuccess && state.student != null) {
          setState(() => _student = state.student!);
        }
        if (state is StudentActionSuccess && state.student == null) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.w, color: colors.text),
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
            if (isParent && _student.isEditable) ...[
              IconButton(
                icon: Icon(Icons.edit_outlined, size: 20.w, color: colors.text),
                onPressed: _onEdit,
              ),
              if (_student.status == ApplicationStatus.applicationCreated)
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded, size: 20.w, color: colors.red),
                  onPressed: _onDelete,
                ),
            ],
          ],
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 40.h),
          children: [
            StudentHeaderCard(student: _student),
            SizedBox(height: 16.h),
            StudentStatusStepper(status: _student.status),
            SizedBox(height: 16.h),
            StudentDetailsCard(student: _student),
            if (_student.examSlotId != null) ...[
              SizedBox(height: 16.h),
              SlotInfoCard(slotId: _student.examSlotId!),
            ],
            if (_student.examScore != null) ...[
              SizedBox(height: 16.h),
              ExamResultCard(score: _student.examScore!, course: _student.assignedCourse),
            ],
            SizedBox(height: 24.h),
            if (!isParent) _contactSection(colors),
            if (isParent) _parentActions(colors),
            if (!isParent) _adminActions(colors),
          ],
        ),
      ),
    );
  }

  Widget _contactSection(AppColors colors) {
    final email = _student.parentEmail;
    final phone = _student.parentPhone;
    if (email == null && phone == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Parent',
          style: AppTextStyles.plusJakartaSans(
              fontSize: 13, fontWeight: FontWeight.w600, color: colors.text),
        ),
        SizedBox(height: 10.h),
        Row(
          children: [
            if (phone != null) ...[
              Expanded(
                child: ContactButton(
                  icon: Icons.call_outlined,
                  label: 'Call',
                  color: colors.primary,
                  onTap: () async {
                    try {
                      await launchUrl(Uri(scheme: 'tel', path: phone),
                          mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
              if (email != null) SizedBox(width: 12.w),
            ],
            if (email != null)
              Expanded(
                child: ContactButton(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  color: colors.accent,
                  onTap: () async {
                    try {
                      await launchUrl(Uri(scheme: 'mailto', path: email),
                          mode: LaunchMode.externalApplication);
                    } catch (_) {}
                  },
                ),
              ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _adminActions(AppColors colors) {
    return switch (_student.status) {
      ApplicationStatus.feeSkipped => StudentActionButton(
          label: 'Enable Payment',
          icon: Icons.payment_outlined,
          color: colors.primary,
          onTap: _onEnablePayment,
        ),
      ApplicationStatus.slotBooked => AdminActionRow(
          primary: StudentActionButton(
            label: 'Enter Exam Score',
            icon: Icons.quiz_outlined,
            color: colors.accent,
            onTap: _onEnterScore,
          ),
          onEditScore: _onEnterScore,
          onEnablePayment:
              _student.paymentStatus != 'paid' ? _onEnablePayment : null,
        ),
      ApplicationStatus.examCompleted when _student.assignedCourse == null =>
        AdminActionRow(
          primary: StudentActionButton(
            label: 'Assign Course',
            icon: Icons.book_outlined,
            color: colors.accent,
            onTap: _onAssignCourse,
          ),
          onEditScore: _onEnterScore,
        ),
      ApplicationStatus.examCompleted => AdminActionRow(
          primary: StudentActionButton(
            label: 'Complete Admission',
            icon: Icons.check_circle_outline_rounded,
            color: colors.primary,
            onTap: _onCompleteAdmission,
          ),
          onEditScore: _onEnterScore,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _parentActions(AppColors colors) {
    return switch (_student.status) {
      ApplicationStatus.applicationCreated => StudentActionButton(
          label: 'Pay Registration Fee',
          icon: Icons.payment_outlined,
          color: colors.primary,
          onTap: _onFeeAction,
        ),
      ApplicationStatus.feePaid || ApplicationStatus.feeSkipped =>
        StudentActionButton(
          label: 'Book Exam Slot',
          icon: Icons.calendar_month_outlined,
          color: colors.accent,
          onTap: _onBookSlot,
        ),
      ApplicationStatus.slotBooked => const StudentInfoBanner(
          icon: Icons.hourglass_top_rounded,
          message: 'Exam slot confirmed. Please arrive on time on the exam day.',
        ),
      ApplicationStatus.examCompleted => const StudentInfoBanner(
          icon: Icons.pending_outlined,
          message: 'Exam completed. The school is reviewing results.',
        ),
      _ => const StudentInfoBanner(
          icon: Icons.celebration_outlined,
          message: 'Congratulations! Admission is complete.',
          success: true,
        ),
    };
  }
}
