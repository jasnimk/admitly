import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class StudentDetailsCard extends StatelessWidget {
  const StudentDetailsCard({super.key, required this.student});
  final StudentEntity student;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
          _row('Date of Birth',
              DateFormat('dd MMM yyyy').format(student.dateOfBirth), context),
          _row('Gender',
              student.gender.name[0].toUpperCase() + student.gender.name.substring(1),
              context),
          _row('Previous School', student.previousSchool, context),
          _row('Applying For', student.applyingGrade, context),
          _row('Applied On', DateFormat('dd MMM yyyy').format(student.createdAt), context,
              isLast: student.paymentStatus == null),
          if (student.paymentStatus != null)
            _row(
              'Fee Status',
              student.paymentStatus![0].toUpperCase() + student.paymentStatus!.substring(1),
              context,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, BuildContext context, {bool isLast = false}) {
    final colors = context.colors;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Row(
            children: [
              Text(label,
                  style: AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey)),
              const Spacer(),
              Text(value,
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, fontWeight: FontWeight.w600, color: colors.text)),
            ],
          ),
        ),
        if (!isLast) Divider(color: colors.border, height: 1),
      ],
    );
  }
}
