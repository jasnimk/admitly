import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExamResultCard extends StatelessWidget {
  const ExamResultCard({super.key, required this.score, this.course});
  final int score;
  final String? course;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final passed = score >= 40;
    final color = passed ? colors.primary : colors.red;

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
                      fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              if (course != null)
                Text('Assigned: $course',
                    style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
