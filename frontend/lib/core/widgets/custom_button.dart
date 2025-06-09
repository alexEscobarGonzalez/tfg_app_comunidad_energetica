import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'loading_indicators.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool fullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? LoadingSpinner(
            size: 10.w,
            strokeWidth: 1,
            color: AppColors.textOnPrimary,
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 10.sp),
                SizedBox(width: 3.w),
              ],
              Text(text),
            ],
          );

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: Size(width ?? (fullWidth ? double.infinity : 50.w), height ?? 24.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
            textStyle: AppTextStyles.button,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.textOnPrimary,
            minimumSize: Size(width ?? (fullWidth ? double.infinity : 50.w), height ?? 24.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
            textStyle: AppTextStyles.button,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 0.5),
            minimumSize: Size(width ?? (fullWidth ? double.infinity : 50.w), height ?? 24.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
            textStyle: AppTextStyles.button,
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          ),
          child: buttonChild,
        );
        break;

      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            minimumSize: Size(width ?? (fullWidth ? double.infinity : 40.w), height ?? 20.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3.r)),
            textStyle: AppTextStyles.button,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          ),
          child: buttonChild,
        );
        break;
    }

    return button;
  }
}

class FloatingActionCustomButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String? tooltip;
  final Color? backgroundColor;
  final bool mini;

  const FloatingActionCustomButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.tooltip,
    this.backgroundColor,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? AppColors.primary,
      mini: mini,
      child: Icon(
        icon,
        size: mini ? 12.sp : 14.sp,
        color: AppColors.textOnPrimary,
      ),
    );
  }
} 