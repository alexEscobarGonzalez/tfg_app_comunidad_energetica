import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum TrendType { up, down, stable, none }

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final TrendType trend;
  final String? change;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isCompact;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.trend = TrendType.none,
    this.change,
    required this.icon,
    required this.color,
    this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double paddingValue = isCompact ? 4.w : 6.w;
    final double iconBgPadding = isCompact ? 2.w : 3.w;
    final double iconSize = isCompact ? 10.sp : 12.sp;
    final double trendIconSize = isCompact ? 6.sp : 7.sp;
    final TextStyle titleStyle = isCompact 
        ? AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500)
        : AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary);
    final TextStyle valueStyle = isCompact
        ? AppTextStyles.headline4.copyWith(fontWeight: FontWeight.bold)
        : AppTextStyles.headline3.copyWith(fontWeight: FontWeight.bold);
    final double verticalSpacing = isCompact ? 2.h : 4.h;
    final double mainVerticalSpacing = isCompact ? 0.5.h : 1.h;

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isCompact ? 2.r : 3.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isCompact ? 2.r : 3.r),
        child: Padding(
          padding: EdgeInsets.all(paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(iconBgPadding),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(isCompact ? 2.r : 3.r),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: iconSize,
                    ),
                  ),
                  if (trend != TrendType.none && change != null && !isCompact)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: _getTrendColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getTrendIcon(),
                            color: _getTrendColor(),
                            size: trendIconSize,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            change!,
                            style: AppTextStyles.caption.copyWith(
                              color: _getTrendColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              SizedBox(height: verticalSpacing),
              
              Text(
                title,
                style: titleStyle,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: mainVerticalSpacing),
              
              Text(
                value,
                style: valueStyle,
                overflow: TextOverflow.ellipsis,
              ),
              
              if (subtitle != null && !isCompact) ...[
                SizedBox(height: mainVerticalSpacing),
                Text(
                  subtitle!,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                  ),
                   overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getTrendColor() {
    switch (trend) {
      case TrendType.up:
        return AppColors.success;
      case TrendType.down:
        return AppColors.error;
      case TrendType.stable:
        return AppColors.warning;
      case TrendType.none:
        return AppColors.textSecondary;
    }
  }

  IconData _getTrendIcon() {
    switch (trend) {
      case TrendType.up:
        return Icons.trending_up;
      case TrendType.down:
        return Icons.trending_down;
      case TrendType.stable:
        return Icons.trending_flat;
      case TrendType.none:
        return Icons.remove;
    }
  }
} 