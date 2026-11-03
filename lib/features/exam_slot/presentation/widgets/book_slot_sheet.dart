import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:admitly/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

Future<bool> showBookSlotSheet(
  BuildContext context, {
  required String studentId,
}) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<ExamSlotBloc>()..add(const ExamSlotsLoadRequested()),
      child: _BookSlotSheet(studentId: studentId),
    ),
  );
  return result ?? false;
}

class _BookSlotSheet extends StatefulWidget {
  const _BookSlotSheet({required this.studentId});
  final String studentId;

  @override
  State<_BookSlotSheet> createState() => _BookSlotSheetState();
}

class _BookSlotSheetState extends State<_BookSlotSheet> {
  String? _selectedSlotId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<ExamSlotBloc, ExamSlotState>(
      listener: (context, state) {
        if (state is ExamSlotBookSuccess) {
          Navigator.pop(context, true);
          AppSnackBar.show(context, 'Exam slot booked!',
              type: SnackBarType.success);
        } else if (state is ExamSlotError) {
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  children: [
                    Text(
                      'Book Exam Slot',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context, false),
                      child: Icon(Icons.close, color: colors.grey, size: 22.w),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  'Select an available slot for the entrance exam',
                  style: AppTextStyles.plusJakartaSans(
                      fontSize: 13, color: colors.grey),
                ),
              ),
              SizedBox(height: 8.h),
              Divider(color: colors.border, height: 1),
              Expanded(
                child: BlocBuilder<ExamSlotBloc, ExamSlotState>(
                  builder: (context, state) {
                    if (state is ExamSlotLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ExamSlotError) {
                      return Center(
                        child: Text(state.message,
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 14, color: colors.error)),
                      );
                    }
                    if (state is ExamSlotLoaded) {
                      if (state.slots.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.event_busy_outlined,
                                  size: 48.w, color: colors.grey),
                              SizedBox(height: 12.h),
                              Text('No slots available',
                                  style: AppTextStyles.plusJakartaSans(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: colors.text)),
                              SizedBox(height: 6.h),
                              Text('Check back later',
                                  style: AppTextStyles.plusJakartaSans(
                                      fontSize: 13, color: colors.grey)),
                            ],
                          ),
                        );
                      }
                      return ListView.separated(
                        controller: scrollController,
                        padding:
                            EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                        itemCount: state.slots.length,
                        separatorBuilder: (_, __) => SizedBox(height: 10.h),
                        itemBuilder: (context, i) => _SlotTile(
                          slot: state.slots[i],
                          isSelected: _selectedSlotId == state.slots[i].id,
                          onTap: () => setState(
                              () => _selectedSlotId = state.slots[i].id),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              BlocBuilder<ExamSlotBloc, ExamSlotState>(
                builder: (context, state) => SafeArea(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: _selectedSlotId == null ||
                                state is ExamSlotLoading
                            ? null
                            : () => context.read<ExamSlotBloc>().add(
                                  ExamSlotBookRequested(
                                    slotId: _selectedSlotId!,
                                    studentId: widget.studentId,
                                  ),
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          disabledBackgroundColor: colors.mist,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r)),
                        ),
                        child: state is ExamSlotLoading
                            ? SizedBox(
                                width: 20.w,
                                height: 20.w,
                                child: const CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Confirm Booking',
                                style: AppTextStyles.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotTile extends StatelessWidget {
  const _SlotTile({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });
  final ExamSlotEntity slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.06)
              : colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? colors.primary : colors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.primary.withValues(alpha: 0.1)
                    : colors.canvas,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 18.w,
                color: isSelected ? colors.primary : colors.grey,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(slot.date),
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.text,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 12.w, color: colors.grey),
                      SizedBox(width: 4.w),
                      Text(slot.timeLabel,
                          style: AppTextStyles.plusJakartaSans(
                              fontSize: 12, color: colors.grey)),
                      SizedBox(width: 10.w),
                      Icon(Icons.location_on_outlined,
                          size: 12.w, color: colors.grey),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(slot.venue,
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 12, color: colors.grey),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      color: colors.primary, size: 20.w)
                else
                  Icon(Icons.radio_button_unchecked,
                      color: colors.border, size: 20.w),
                SizedBox(height: 4.h),
                Text(
                  '${slot.remaining} left',
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 11,
                    color:
                        slot.remaining < 5 ? colors.orange : colors.grey,
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
