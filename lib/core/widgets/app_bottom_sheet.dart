import 'package:admitly/core/constants/app_colors.dart';
import 'package:admitly/core/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Wraps [showModalBottomSheet] with the app's standard sheet chrome:
/// keyboard-aware padding, rounded top corners, handle bar, and optional title.
class AppBottomSheet {
  AppBottomSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    String? title,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheetContent(title: title, child: child),
    );
  }
}

class _BottomSheetContent extends StatelessWidget {
  const _BottomSheetContent({required this.child, this.title});

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSheetHandle(),
              if (title != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 0),
                  child: Text(
                    title!,
                    style: AppTextStyles.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.text,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Divider(height: 1, color: colors.border),
                SizedBox(height: 8.h),
              ],
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 32.h),
                  child: child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The draggable handle bar shown at the top of every bottom sheet.
class AppSheetHandle extends StatelessWidget {
  const AppSheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 12.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: colors.border,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}

/// Icon-box + title + optional subtitle row used as the header of action sheets.
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = iconColor ?? colors.primary;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 22.w, color: color),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.plusJakartaSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: AppTextStyles.plusJakartaSans(fontSize: 12, color: colors.grey),
              ),
          ],
        ),
      ],
    );
  }
}
