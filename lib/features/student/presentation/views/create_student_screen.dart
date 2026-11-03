import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:admitly/core/widgets/app_snack_bar.dart';
import 'package:admitly/features/student/domain/entities/student_entity.dart';
import 'package:admitly/features/student/presentation/bloc/student_bloc.dart';
import 'package:admitly/features/student/presentation/bloc/student_event.dart';
import 'package:admitly/features/student/presentation/bloc/student_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

class CreateStudentScreen extends StatefulWidget {
  const CreateStudentScreen({
    super.key,
    required this.parentId,
    this.existing,
  });

  final String parentId;
  final StudentEntity? existing;

  @override
  State<CreateStudentScreen> createState() => _CreateStudentScreenState();
}

class _CreateStudentScreenState extends State<CreateStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _schoolCtrl = TextEditingController();

  DateTime? _dob;
  Gender _gender = Gender.male;
  String? _grade;

  bool get _isEditing => widget.existing != null;

  static const _grades = ['Grade 1', 'Grade 2', 'Grade 3', 'Grade 4', 'Grade 5',
      'Grade 6', 'Grade 7', 'Grade 8', 'Grade 9', 'Grade 10'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final s = widget.existing!;
      _nameCtrl.text = s.name;
      _schoolCtrl.text = s.previousSchool;
      _dob = s.dateOfBirth;
      _gender = s.gender;
      _grade = s.applyingGrade;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _schoolCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(2015),
      firstDate: DateTime(2005),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_dob == null) {
      AppSnackBar.show(context, 'Please select date of birth', type: SnackBarType.error);
      return;
    }
    if (_grade == null) {
      AppSnackBar.show(context, 'Please select applying grade', type: SnackBarType.error);
      return;
    }

    final entity = StudentEntity(
      id: widget.existing?.id ?? '',
      parentId: widget.parentId,
      name: _nameCtrl.text.trim(),
      dateOfBirth: _dob!,
      gender: _gender,
      previousSchool: _schoolCtrl.text.trim(),
      applyingGrade: _grade!,
      status: widget.existing?.status ?? ApplicationStatus.applicationCreated,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      paymentStatus: widget.existing?.paymentStatus,
      examSlotId: widget.existing?.examSlotId,
      examScore: widget.existing?.examScore,
      assignedCourse: widget.existing?.assignedCourse,
    );

    if (_isEditing) {
      context.read<StudentBloc>().add(StudentUpdateRequested(entity));
    } else {
      context.read<StudentBloc>().add(StudentCreateRequested(entity));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BlocListener<StudentBloc, StudentState>(
      listener: (context, state) {
        if (state is StudentActionSuccess) {
          AppSnackBar.show(
            context,
            _isEditing ? 'Student updated' : 'Student application created',
            type: SnackBarType.success,
          );
          Navigator.pop(context);
        } else if (state is StudentError) {
          AppSnackBar.show(context, state.message, type: SnackBarType.error);
        }
      },
      child: Scaffold(
        backgroundColor: colors.background,
        appBar: AppBar(
          backgroundColor: colors.background,
          elevation: 0,
          title: Text(
            _isEditing ? 'Edit Student' : 'New Student Application',
            style: AppTextStyles.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.text,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            children: [
              _label(context, 'Student Name'),
              SizedBox(height: 8.h),
              _field(
                controller: _nameCtrl,
                hint: 'Full name',
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                colors: colors,
              ),
              SizedBox(height: 20.h),
              _label(context, 'Date of Birth'),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 18.w, color: colors.grey),
                      SizedBox(width: 12.w),
                      Text(
                        _dob == null
                            ? 'Select date'
                            : DateFormat('dd MMM yyyy').format(_dob!),
                        style: AppTextStyles.plusJakartaSans(
                          fontSize: 14,
                          color: _dob == null ? colors.grey : colors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              _label(context, 'Gender'),
              SizedBox(height: 8.h),
              Row(
                children: Gender.values.map((g) {
                  final selected = _gender == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _gender = g),
                      child: Container(
                        margin: EdgeInsets.only(right: g != Gender.values.last ? 8.w : 0),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        decoration: BoxDecoration(
                          color: selected ? colors.primary : colors.surface,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: selected ? colors.primary : colors.border,
                          ),
                        ),
                        child: Text(
                          g.name[0].toUpperCase() + g.name.substring(1),
                          textAlign: TextAlign.center,
                          style: AppTextStyles.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : colors.text,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20.h),
              _label(context, 'Previous School'),
              SizedBox(height: 8.h),
              _field(
                controller: _schoolCtrl,
                hint: 'Name of previous school',
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                colors: colors,
              ),
              SizedBox(height: 20.h),
              _label(context, 'Applying Grade'),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _grade,
                    hint: Text('Select grade',
                        style: AppTextStyles.plusJakartaSans(
                            fontSize: 14, color: colors.grey)),
                    dropdownColor: colors.surface,
                    items: _grades
                        .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(g,
                                  style: AppTextStyles.plusJakartaSans(
                                      fontSize: 14, color: colors.text)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _grade = v),
                  ),
                ),
              ),
              SizedBox(height: 36.h),
              BlocBuilder<StudentBloc, StudentState>(
                builder: (context, state) => AppButton(
                  label: _isEditing ? 'Save Changes' : 'Submit Application',
                  onPressed: _submit,
                  isLoading: state is StudentLoading,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: AppTextStyles.plusJakartaSans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: context.colors.text,
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    required AppColors colors,
  }) =>
      TextFormField(
        controller: controller,
        validator: validator,
        style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
          filled: true,
          fillColor: colors.surface,
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
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      );
}
