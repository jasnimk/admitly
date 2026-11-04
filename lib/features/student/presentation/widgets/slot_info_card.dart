import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/domain/usecases/get_all_slots_usecase.dart';
import 'package:admitly/injection_container.dart' show sl;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class SlotInfoCard extends StatefulWidget {
  const SlotInfoCard({super.key, required this.slotId});
  final String slotId;

  @override
  State<SlotInfoCard> createState() => _SlotInfoCardState();
}

class _SlotInfoCardState extends State<SlotInfoCard> {
  ExamSlotEntity? _slot;

  @override
  void initState() {
    super.initState();
    _loadSlot();
  }

  Future<void> _loadSlot() async {
    final result = await sl<GetAllSlotsUseCase>().call();
    result.fold((_) {}, (slots) {
      final match = slots.where((s) => s.id == widget.slotId).firstOrNull;
      if (match != null && mounted) setState(() => _slot = match);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final slot = _slot;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colors.accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.event_available_outlined, color: colors.accent, size: 22.w),
          SizedBox(width: 12.w),
          Expanded(
            child: slot == null
                ? Text('Exam Slot Booked',
                    style: AppTextStyles.plusJakartaSans(
                        fontSize: 13, fontWeight: FontWeight.w600, color: colors.accent))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Exam Slot Confirmed',
                          style: AppTextStyles.plusJakartaSans(
                              fontSize: 13, fontWeight: FontWeight.w700, color: colors.accent)),
                      SizedBox(height: 4.h),
                      Text(
                        '${DateFormat('EEE, dd MMM yyyy').format(slot.date)}  ·  ${slot.timeLabel}',
                        style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.accent),
                      ),
                      Text(
                        slot.venue,
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 12, color: colors.accent.withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
