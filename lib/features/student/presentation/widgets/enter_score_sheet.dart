import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<int?> showEnterScoreSheet(
  BuildContext context, {
  required String studentName,
  int? existingScore,
}) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EnterScoreSheet(
      studentName: studentName,
      existingScore: existingScore,
    ),
  );
}

class _EnterScoreSheet extends StatefulWidget {
  const _EnterScoreSheet({required this.studentName, this.existingScore});
  final String studentName;
  final int? existingScore;

  @override
  State<_EnterScoreSheet> createState() => _EnterScoreSheetState();
}

class _EnterScoreSheetState extends State<_EnterScoreSheet> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(
      text: widget.existingScore != null ? '${widget.existingScore}' : '',
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    final v = int.tryParse(_ctrl.text.trim());
    if (v == null || v < 0 || v > 100) {
      setState(() => _error = 'Enter a score between 0 and 100');
      return;
    }
    Navigator.pop(context, v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
            // Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.quiz_outlined, size: 22.w, color: colors.primary),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Exam Score',
                      style: AppTextStyles.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.text,
                      ),
                    ),
                    Text(
                      widget.studentName,
                      style: AppTextStyles.plusJakartaSans(
                          fontSize: 12, color: colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            // Score field
            TextField(
              controller: _ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: AppTextStyles.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
              textAlign: TextAlign.center,
              onChanged: (_) => setState(() => _error = null),
              decoration: InputDecoration(
                hintText: '—',
                hintStyle: AppTextStyles.plusJakartaSans(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: colors.grey.withValues(alpha: 0.4),
                ),
                suffixText: '/ 100',
                suffixStyle: AppTextStyles.plusJakartaSans(
                  fontSize: 18,
                  color: colors.grey,
                ),
                filled: true,
                fillColor: colors.canvas,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
                errorText: _error,
                errorStyle: AppTextStyles.plusJakartaSans(
                    fontSize: 12, color: colors.error),
              ),
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Pass mark: 40 / 100',
                style: AppTextStyles.plusJakartaSans(
                    fontSize: 12, color: colors.grey),
              ),
            ),
            SizedBox(height: 24.h),
            AppButton(label: 'Save Score', onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
