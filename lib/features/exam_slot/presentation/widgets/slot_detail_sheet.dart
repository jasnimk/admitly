import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:admitly/features/exam_slot/presentation/widgets/create_slot_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

Future<void> showSlotDetailSheet(BuildContext context, ExamSlotEntity slot) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ExamSlotBloc>(),
      child: _SlotDetailSheet(slot: slot),
    ),
  );
}

class _SlotDetailSheet extends StatefulWidget {
  const _SlotDetailSheet({required this.slot});
  final ExamSlotEntity slot;

  @override
  State<_SlotDetailSheet> createState() => _SlotDetailSheetState();
}

class _SlotDetailSheetState extends State<_SlotDetailSheet> {
  bool _deleting = false;

  Future<void> _onDelete() async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'Delete Slot',
          style: AppTextStyles.plusJakartaSans(
              fontSize: 16, fontWeight: FontWeight.w700, color: colors.text),
        ),
        content: Text(
          'This will permanently delete the slot. Students who booked it won\'t be notified automatically.',
          style:
              AppTextStyles.plusJakartaSans(fontSize: 13, color: colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 13, color: colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => _deleting = true);
      context
          .read<ExamSlotBloc>()
          .add(ExamSlotDeleteRequested(widget.slot.id));
    }
  }

  void _onEdit() {
    Navigator.pop(context);
    showCreateSlotSheet(context, slot: widget.slot);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final slot = widget.slot;
    final isFull = !slot.isAvailable;
    final statusColor = isFull ? colors.red : colors.primary;
    final fill = slot.capacity > 0 ? slot.bookedCount / slot.capacity : 0.0;

    return BlocListener<ExamSlotBloc, ExamSlotState>(
      listener: (context, state) {
        if (state is ExamSlotLoaded || state is ExamSlotError) {
          if (_deleting) {
            Navigator.pop(context);
            if (state is ExamSlotError) {
              AppSnackBar.show(context, state.message,
                  type: SnackBarType.error);
            } else {
              AppSnackBar.show(context, 'Slot deleted',
                  type: SnackBarType.success);
            }
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            // Header row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.calendar_month_rounded,
                      size: 22.w, color: colors.primary),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, dd MMMM yyyy').format(slot.date),
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.text),
                      ),
                      if (slot.timeLabel.isNotEmpty)
                        Text(slot.timeLabel,
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 12, color: colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isFull ? 'Full' : '${slot.remaining} left',
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Divider(color: colors.border, height: 1),
            SizedBox(height: 20.h),
            // Detail rows
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Venue',
              value: slot.venue.isNotEmpty ? slot.venue : '—',
              colors: colors,
            ),
            SizedBox(height: 14.h),
            _DetailRow(
              icon: Icons.people_outline_rounded,
              label: 'Capacity',
              value: '${slot.capacity} seats',
              colors: colors,
            ),
            SizedBox(height: 14.h),
            _DetailRow(
              icon: Icons.how_to_reg_outlined,
              label: 'Booked',
              value: '${slot.bookedCount} of ${slot.capacity}',
              colors: colors,
            ),
            SizedBox(height: 16.h),
            // Progress bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: fill,
                      minHeight: 6.h,
                      backgroundColor: colors.border,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  '${(fill * 100).round()}%',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _deleting ? null : _onDelete,
                    icon: _deleting
                        ? SizedBox(
                            width: 14.w,
                            height: 14.w,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: colors.red),
                          )
                        : Icon(Icons.delete_outline_rounded,
                            size: 18.w, color: colors.red),
                    label: Text(
                      'Delete',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(color: colors.red.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: AppButton(
                    label: 'Edit Slot',
                    onPressed: _onEdit,
                    icon: Icon(Icons.edit_outlined, size: 18.w, color: context.colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16.w, color: colors.grey),
        SizedBox(width: 10.w),
        Text(
          label,
          style: AppTextStyles.plusJakartaSans(
              fontSize: 13, color: colors.grey),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text),
        ),
      ],
    );
  }
}
