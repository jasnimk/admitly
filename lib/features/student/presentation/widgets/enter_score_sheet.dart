import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:admitly/core/widgets/app_bottom_sheet.dart';
import 'package:admitly/core/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<int?> showEnterScoreSheet(
  BuildContext context, {
  required String studentName,
  int? existingScore,
}) {
  return AppBottomSheet.show<int>(
    context,
    child: _EnterScoreContent(
      studentName: studentName,
      existingScore: existingScore,
    ),
  );
}

class _EnterScoreContent extends StatefulWidget {
  const _EnterScoreContent({required this.studentName, this.existingScore});
  final String studentName;
  final int? existingScore;

  @override
  State<_EnterScoreContent> createState() => _EnterScoreContentState();
}

class _EnterScoreContentState extends State<_EnterScoreContent> {
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSheetHeader(
          icon: Icons.quiz_outlined,
          title: 'Enter Exam Score',
          subtitle: widget.studentName,
        ),
        SizedBox(height: 24.h),
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
            suffixStyle: AppTextStyles.plusJakartaSans(fontSize: 18, color: colors.grey),
            filled: true,
            fillColor: colors.canvas,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: BorderSide.none,
            ),
            errorText: _error,
            errorStyle: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.error),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: Text(
            'Pass mark: 40 / 100',
            style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey),
          ),
        ),
        SizedBox(height: 24.h),
        AppButton(label: 'Save Score', onPressed: _submit),
      ],
    );
  }
}
