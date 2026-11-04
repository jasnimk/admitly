import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_bottom_sheet.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<String?> showAssignCourseSheet(
  BuildContext context, {
  String? existingCourse,
}) {
  return AppBottomSheet.show<String>(
    context,
    child: _AssignCourseContent(existingCourse: existingCourse),
  );
}

class _AssignCourseContent extends StatefulWidget {
  const _AssignCourseContent({this.existingCourse});
  final String? existingCourse;

  @override
  State<_AssignCourseContent> createState() => _AssignCourseContentState();
}

class _AssignCourseContentState extends State<_AssignCourseContent> {
  late final TextEditingController _ctrl;
  String? _error;

  static const _suggestions = [
    'Grade 1 — General',
    'Grade 2 — General',
    'Grade 3 — General',
    'Grade 4 — Science',
    'Grade 5 — Science',
    'Grade 6 — Science',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.existingCourse ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = _ctrl.text.trim();
    if (v.isEmpty) {
      setState(() => _error = 'Please enter or select a course');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSheetHeader(
          icon: Icons.school_outlined,
          title: widget.existingCourse != null ? 'Update Course' : 'Assign Course',
        ),
        SizedBox(height: 20.h),
        Text(
          'Quick pick',
          style: AppTextStyles.plusJakartaSans(
              fontSize: 12, fontWeight: FontWeight.w600, color: colors.grey),
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _suggestions.map((s) {
            final selected = _ctrl.text.trim() == s;
            return GestureDetector(
              onTap: () => setState(() {
                _ctrl.text = s;
                _ctrl.selection =
                    TextSelection.fromPosition(TextPosition(offset: s.length));
                _error = null;
              }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: selected ? colors.primary : colors.canvas,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: selected ? colors.primary : colors.border,
                  ),
                ),
                child: Text(
                  s,
                  style: AppTextStyles.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected ? colors.white : colors.text,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 20.h),
        TextField(
          controller: _ctrl,
          onChanged: (_) => setState(() => _error = null),
          style: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.text),
          decoration: InputDecoration(
            hintText: 'Or type a custom course…',
            hintStyle: AppTextStyles.plusJakartaSans(fontSize: 14, color: colors.grey),
            filled: true,
            fillColor: colors.canvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            errorText: _error,
            errorStyle: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.error),
          ),
        ),
        SizedBox(height: 24.h),
        AppButton(label: 'Assign', onPressed: _submit),
      ],
    );
  }
}
