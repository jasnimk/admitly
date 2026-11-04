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

Future<void> showCreateSlotSheet(BuildContext context, {ExamSlotEntity? slot}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: context.read<ExamSlotBloc>(),
      child: _CreateSlotSheet(slot: slot),
    ),
  );
}

class _CreateSlotSheet extends StatefulWidget {
  const _CreateSlotSheet({this.slot});
  final ExamSlotEntity? slot;

  @override
  State<_CreateSlotSheet> createState() => _CreateSlotSheetState();
}

class _CreateSlotSheetState extends State<_CreateSlotSheet> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _date;
  TimeOfDay? _fromTime;
  TimeOfDay? _toTime;
  String? _venue;
  late final TextEditingController _capacityCtrl;
  bool _submitting = false;

  bool get _isEdit => widget.slot != null;

  static const _venueOptions = [
    'Main Hall',
    'Conference Room, Block A',
    'Conference Room, Block B',
    'Auditorium',
    'Library Hall',
    'Examination Room 1',
    'Examination Room 2',
    'Computer Lab',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.slot;
    _date = s?.date;
    _venue = s?.venue;
    _capacityCtrl = TextEditingController(
      text: s != null ? s.capacity.toString() : '30',
    );
  }

  @override
  void dispose() {
    _capacityCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: ctx.colors.primary,
            onPrimary: Colors.white,
            surface: ctx.colors.surface,
            onSurface: ctx.colors.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickFromTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _fromTime ?? const TimeOfDay(hour: 9, minute: 0),
      builder: (ctx, child) => _timePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _fromTime = picked);
  }

  Future<void> _pickToTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _toTime ??
          TimeOfDay(
            hour: (_fromTime?.hour ?? 9) + 2,
            minute: _fromTime?.minute ?? 0,
          ),
      builder: (ctx, child) => _timePickerTheme(ctx, child),
    );
    if (picked != null) setState(() => _toTime = picked);
  }

  Widget _timePickerTheme(BuildContext ctx, Widget? child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: ctx.colors.primary,
            onPrimary: Colors.white,
            surface: ctx.colors.surface,
            onSurface: ctx.colors.text,
          ),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: ctx.colors.surface,
          ),
        ),
        child: child!,
      );

  String _formatTime(TimeOfDay t) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, t.hour, t.minute);
    return DateFormat('h:mm a').format(dt);
  }

  String get _timeLabel {
    if (_fromTime == null || _toTime == null) {
      // In edit mode, keep the existing label if no new times were picked
      return widget.slot?.timeLabel ?? '';
    }
    return '${_formatTime(_fromTime!)} – ${_formatTime(_toTime!)}';
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_date == null) {
      AppSnackBar.show(context, 'Please select a date', type: SnackBarType.error);
      return;
    }
    if (!_isEdit && (_fromTime == null || _toTime == null)) {
      AppSnackBar.show(context, 'Please select from and to time',
          type: SnackBarType.error);
      return;
    }
    if (_venue == null) {
      AppSnackBar.show(context, 'Please select a venue', type: SnackBarType.error);
      return;
    }
    final capacity = int.tryParse(_capacityCtrl.text.trim()) ?? 0;
    if (capacity <= 0) {
      AppSnackBar.show(context, 'Capacity must be greater than 0',
          type: SnackBarType.error);
      return;
    }
    setState(() => _submitting = true);
    if (_isEdit) {
      context.read<ExamSlotBloc>().add(
            ExamSlotUpdateRequested(
              ExamSlotEntity(
                id: widget.slot!.id,
                date: _date!,
                timeLabel: _timeLabel,
                venue: _venue!,
                capacity: capacity,
                bookedCount: widget.slot!.bookedCount,
              ),
            ),
          );
    } else {
      context.read<ExamSlotBloc>().add(
            ExamSlotCreateRequested(
              ExamSlotEntity(
                id: '',
                date: _date!,
                timeLabel: _timeLabel,
                venue: _venue!,
                capacity: capacity,
                bookedCount: 0,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<ExamSlotBloc, ExamSlotState>(
      listener: (context, state) {
        if (state is ExamSlotCreateSuccess) {
          setState(() => _submitting = false);
          Navigator.pop(context);
          AppSnackBar.show(context, 'Exam slot created successfully',
              type: SnackBarType.success);
        } else if (state is ExamSlotUpdateSuccess) {
          setState(() => _submitting = false);
          Navigator.pop(context);
          AppSnackBar.show(context, 'Exam slot updated successfully',
              type: SnackBarType.success);
        } else if (state is ExamSlotError) {
          setState(() => _submitting = false);
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: DraggableScrollableSheet(
        initialChildSize: 0.78,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
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
                // Header
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.calendar_month_rounded,
                            size: 22.w, color: colors.primary),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEdit ? 'Edit Exam Slot' : 'Create Exam Slot',
                            style: AppTextStyles.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: colors.text,
                            ),
                          ),
                          Text(
                            _isEdit
                                ? 'Update slot details'
                                : 'Schedule a new entrance exam session',
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 12, color: colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Divider(color: colors.border, height: 1),
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 32.h),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _Label(text: 'Date', colors: colors),
                          SizedBox(height: 8.h),
                          _PickerTile(
                            icon: Icons.calendar_today_outlined,
                            label: _date == null
                                ? 'Select exam date'
                                : DateFormat('EEEE, dd MMMM yyyy').format(_date!),
                            hasValue: _date != null,
                            onTap: _pickDate,
                            colors: colors,
                          ),
                          SizedBox(height: 20.h),
                          _Label(
                            text: _isEdit
                                ? 'Time (tap to change)'
                                : 'Time',
                            colors: colors,
                          ),
                          SizedBox(height: 8.h),
                          if (_isEdit && _fromTime == null && _toTime == null)
                            _PickerTile(
                              icon: Icons.access_time_rounded,
                              label: widget.slot!.timeLabel.isNotEmpty
                                  ? widget.slot!.timeLabel
                                  : 'No time set',
                              hasValue: widget.slot!.timeLabel.isNotEmpty,
                              onTap: _pickFromTime,
                              colors: colors,
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: _PickerTile(
                                    icon: Icons.schedule_rounded,
                                    label: _fromTime == null ? 'From' : _formatTime(_fromTime!),
                                    hasValue: _fromTime != null,
                                    onTap: _pickFromTime,
                                    colors: colors,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                                  child: Text('–',
                                      style: AppTextStyles.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: colors.grey)),
                                ),
                                Expanded(
                                  child: _PickerTile(
                                    icon: Icons.schedule_rounded,
                                    label: _toTime == null ? 'To' : _formatTime(_toTime!),
                                    hasValue: _toTime != null,
                                    onTap: _pickToTime,
                                    colors: colors,
                                  ),
                                ),
                              ],
                            ),
                          if (_isEdit && _fromTime != null)
                            Padding(
                              padding: EdgeInsets.only(top: 6.h),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _fromTime = null;
                                    _toTime = null;
                                  });
                                },
                                child: Text(
                                  'Reset to original time',
                                  style: AppTextStyles.plusJakartaSans(
                                      fontSize: 12, color: colors.grey),
                                ),
                              ),
                            ),
                          SizedBox(height: 20.h),
                          _Label(text: 'Venue', colors: colors),
                          SizedBox(height: 8.h),
                          DropdownButtonFormField<String>(
                            initialValue: _venue,
                            hint: Text(
                              'Select a venue',
                              style: AppTextStyles.plusJakartaSans(
                                  fontSize: 14, color: colors.grey),
                            ),
                            style: AppTextStyles.plusJakartaSans(
                                fontSize: 14, color: colors.text),
                            dropdownColor: colors.surface,
                            icon: Icon(Icons.keyboard_arrow_down_rounded,
                                color: colors.grey),
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.location_on_outlined,
                                  size: 18.w, color: colors.grey),
                              filled: true,
                              fillColor: colors.surface,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 14.w, vertical: 14.h),
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
                                borderSide: BorderSide(
                                    color: colors.primary, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r),
                                borderSide: BorderSide(color: colors.red),
                              ),
                            ),
                            items: _venueOptions
                                .map((v) => DropdownMenuItem(
                                      value: v,
                                      child: Text(v),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _venue = v),
                            validator: (v) =>
                                v == null ? 'Please select a venue' : null,
                          ),
                          SizedBox(height: 20.h),
                          _Label(text: 'Capacity', colors: colors),
                          SizedBox(height: 8.h),
                          _InputField(
                            controller: _capacityCtrl,
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
                          SizedBox(height: 32.h),
                          AppButton(
                            label: _isEdit ? 'Update Slot' : 'Create Slot',
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
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text, required this.colors});
  final String text;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: colors.text,
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.onTap,
    required this.colors,
  });
  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: hasValue
              ? colors.primary.withValues(alpha: 0.06)
              : colors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasValue ? colors.primary.withValues(alpha: 0.4) : colors.border,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 16.w,
                color: hasValue ? colors.primary : colors.grey),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  color: hasValue ? colors.text : colors.grey,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.colors,
    this.keyboardType,
    this.validator,
  });
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final AppColors colors;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
        prefixIcon: Icon(icon, size: 18.w, color: colors.grey),
        filled: true,
        fillColor: colors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
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
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colors.red, width: 1.5),
        ),
      ),
    );
  }
}
