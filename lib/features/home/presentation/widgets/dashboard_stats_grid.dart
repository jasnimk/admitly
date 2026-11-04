import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardStatsGrid extends StatelessWidget {
  const DashboardStatsGrid({
    super.key,
    required this.pending,
    required this.feePaid,
    required this.slotBooked,
    required this.examDone,
  });
  final int pending;
  final int feePaid;
  final int slotBooked;
  final int examDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.hourglass_empty_rounded,
                label: 'Pending',
                value: pending,
                color: colors.subtle,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.receipt_long_outlined,
                label: 'Fee Paid',
                value: feePaid,
                color: colors.accent,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: DashboardStatCard(
                icon: Icons.event_available_outlined,
                label: 'Slot Booked',
                value: slotBooked,
                color: colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: DashboardStatCard(
                icon: Icons.assignment_turned_in_outlined,
                label: 'Exam Done',
                value: examDone,
                color: colors.subtle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
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
                style: AppTextStyles.plusJakartaSans(fontSize: 11, color: colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
