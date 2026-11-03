import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:admitly/features/exam_slot/presentation/widgets/slot_detail_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class ExamSlotsScreen extends StatefulWidget {
  const ExamSlotsScreen({super.key});

  @override
  State<ExamSlotsScreen> createState() => _ExamSlotsScreenState();
}

class _ExamSlotsScreenState extends State<ExamSlotsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExamSlotBloc>().add(const ExamAllSlotsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocBuilder<ExamSlotBloc, ExamSlotState>(
      builder: (context, state) {
        if (state is ExamSlotLoading) {
          return Center(child: CircularProgressIndicator(color: colors.primary));
        }
        if (state is ExamSlotError) {
          return Center(
            child: Text(state.message,
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 14, color: colors.error)),
          );
        }
        final slots = state is ExamSlotLoaded ? state.slots : <ExamSlotEntity>[];

        return RefreshIndicator(
          onRefresh: () async =>
              context.read<ExamSlotBloc>().add(const ExamAllSlotsLoadRequested()),
          child: slots.isEmpty
              ? ListView(
                  children: [
                    SizedBox(height: 100.h),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.calendar_month_outlined,
                              size: 56.w, color: colors.grey),
                          SizedBox(height: 16.h),
                          Text('No exam slots yet',
                              style: AppTextStyles.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: colors.text)),
                          SizedBox(height: 6.h),
                          Text('Tap + to create a slot',
                              style: AppTextStyles.plusJakartaSans(
                                  fontSize: 13, color: colors.grey)),
                        ],
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  itemCount: slots.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) =>
                      _SlotCard(slot: slots[i], colors: colors),
                ),
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  const _SlotCard({required this.slot, required this.colors});
  final ExamSlotEntity slot;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isFull = !slot.isAvailable;
    final statusColor = isFull ? colors.red : colors.primary;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => showSlotDetailSheet(context, slot),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      isFull ? 'Full' : '${slot.remaining} seats left',
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${slot.bookedCount}/${slot.capacity}',
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 12, color: colors.grey),
                  ),
                  SizedBox(width: 6.w),
                  Icon(Icons.chevron_right_rounded,
                      size: 18.w, color: colors.grey),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 14.w, color: colors.grey),
                  SizedBox(width: 6.w),
                  Text(
                    DateFormat('EEE, dd MMM yyyy').format(slot.date),
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colors.text),
                  ),
                ],
              ),
              if (slot.timeLabel.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 14.w, color: colors.grey),
                    SizedBox(width: 6.w),
                    Text(slot.timeLabel,
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 12, color: colors.grey)),
                  ],
                ),
              ],
              if (slot.venue.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 14.w, color: colors.grey),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(slot.venue,
                          style: AppTextStyles.plusJakartaSans(
                              fontSize: 12, color: colors.grey),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 10.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: slot.capacity > 0
                      ? slot.bookedCount / slot.capacity
                      : 0.0,
                  minHeight: 4.h,
                  backgroundColor: colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
