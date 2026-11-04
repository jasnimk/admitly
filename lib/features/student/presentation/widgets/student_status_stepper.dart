import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StudentStatusStepper extends StatelessWidget {
  const StudentStatusStepper({super.key, required this.status});
  final ApplicationStatus status;

  static const _steps = [
    (ApplicationStatus.applicationCreated, 'Applied',     Icons.assignment_outlined),
    (ApplicationStatus.feePaid,            'Fee',         Icons.receipt_outlined),
    (ApplicationStatus.slotBooked,         'Slot Booked', Icons.event_outlined),
    (ApplicationStatus.examCompleted,      'Exam',        Icons.quiz_outlined),
    (ApplicationStatus.admissionCompleted, 'Admitted',    Icons.school_outlined),
  ];

  int get _currentIndex {
    if (status == ApplicationStatus.feeSkipped) return 1;
    return _steps.indexWhere((s) => s.$1 == status);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                final done = i ~/ 2 < current;
                return Expanded(
                  child: Container(height: 2.h, color: done ? colors.primary : colors.border),
                );
              }
              final stepIndex = i ~/ 2;
              final done   = stepIndex < current;
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
                      color: done || active ? colors.primary : colors.background,
                      border: Border.all(
                        color: done || active ? colors.primary : colors.border,
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      done ? Icons.check_rounded : icon,
                      size: 14.w,
                      color: done || active ? colors.white : colors.grey,
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
                        fontWeight: active ? FontWeight.w700 : FontWeight.w400,
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
