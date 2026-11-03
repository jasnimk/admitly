import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/exam_slot/domain/entities/exam_slot_entity.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_bloc.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_event.dart';
import 'package:admitly/features/exam_slot/presentation/bloc/exam_slot_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

Future<void> showCreateSlotSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ExamSlotBloc>(),
      child: const _CreateSlotSheet(),
    ),
  );
}

class _CreateSlotSheet extends StatefulWidget {
  const _CreateSlotSheet();

  @override
  State<_CreateSlotSheet> createState() => _CreateSlotSheetState();
}

class _CreateSlotSheetState extends State<_CreateSlotSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  final _timeCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController(text: '30');
  bool _submitting = false;

  @override
  void dispose() {
    _timeCtrl.dispose();
    _venueCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _date == null) {
      if (_date == null) {
        AppSnackBar.show(context, 'Please select a date',
            type: SnackBarType.error);
      }
      return;
    }
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 0;
    if (capacity <= 0) {
      AppSnackBar.show(context, 'Capacity must be greater than 0',
          type: SnackBarType.error);
      return;
    }
    setState(() => _submitting = true);
    context.read<ExamSlotBloc>().add(
          ExamSlotCreateRequested(
            ExamSlotEntity(
              id: '',
              date: _date!,
              timeLabel: _timeCtrl.text.trim(),
              venue: _venueCtrl.text.trim(),
              capacity: capacity,
              bookedCount: 0,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<ExamSlotBloc, ExamSlotState>(
      listener: (context, state) {
        if (state is ExamSlotCreateSuccess) {
          setState(() => _submitting = false);
          Navigator.pop(context);
          AppSnackBar.show(context, 'Exam slot created',
              type: SnackBarType.success);
        } else if (state is ExamSlotError) {
          setState(() => _submitting = false);
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        minChildSize: 0.4,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            ),
            child: Column(
              children: [
                _SheetHandle(colors: colors),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding:
                        EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Create Exam Slot',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          _DatePicker(
                            date: _date,
                            onTap: _pickDate,
                            colors: colors,
                          ),
                          SizedBox(height: 14.h),
                          _Field(
                            controller: _timeCtrl,
                            label: 'Time',
                            hint: 'e.g. 9:00 AM – 11:00 AM',
                            icon: Icons.access_time_rounded,
                            colors: colors,
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                          ),
                          SizedBox(height: 14.h),
                          _Field(
                            controller: _venueCtrl,
                            label: 'Venue',
                            hint: 'e.g. Main Hall, Block A',
                            icon: Icons.location_on_outlined,
                            colors: colors,
                            validator: (v) =>
                                v == null || v.trim().isEmpty
                                    ? 'Required'
                                    : null,
                          ),
                          SizedBox(height: 14.h),
                          _Field(
                            controller: _capacityCtrl,
                            label: 'Capacity',
                            hint: '30',
                            icon: Icons.people_outline_rounded,
                            keyboardType: TextInputType.number,
                            colors: colors,
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n <= 0) return 'Enter a valid number';
                              return null;
                            },
                          ),
                          SizedBox(height: 24.h),
                          AppButton(
                            label: 'Create Slot',
                            isLoading: _submitting,
                            onPressed: _submit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          width: 36.w,
          height: 4.h,
          decoration: BoxDecoration(
            color: colors.grey.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker(
      {required this.date, required this.onTap, required this.colors});
  final DateTime? date;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_outlined,
                size: 18.w, color: colors.grey),
            SizedBox(width: 10.w),
            Text(
              date == null
                  ? 'Select Date'
                  : DateFormat('EEE, dd MMM yyyy').format(date!),
              style: AppTextStyles.plusJakartaSans(
                fontSize: 14,
                color: date == null ? colors.grey : colors.text,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, size: 18.w, color: colors.grey),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.colors,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final AppColors colors;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colors.text),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
            prefixIcon: Icon(icon, size: 18.w, color: colors.grey),
            filled: true,
            fillColor: colors.surface,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: colors.red),
            ),
          ),
        ),
      ],
    );
  }
}
