import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ConfigurationStep {
  final String title;
  final String description;
  final IconData icon;
  final bool isCompleted;
  final bool isActive;
  final VoidCallback? onTap;
  final String? warningMessage;

  ConfigurationStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.isCompleted,
    required this.isActive,
    this.onTap,
    this.warningMessage,
  });
}

class StepProgressIndicator extends StatelessWidget {
  final List<ConfigurationStep> steps;
  final double progress;

  const StepProgressIndicator({
    super.key,
    required this.steps,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con progreso
            Row(
              children: [
                Text(
                  'Configuración del Proyecto',
                  style: AppTextStyles.headline4.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12.h),
            
            // Barra de progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 8.h,
              ),
            ),
            
            SizedBox(height: 20.h),
            
            // Lista de pasos
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: steps.length,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final step = steps[index];
                return _buildStepItem(step);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem(ConfigurationStep step) {
    Color stepColor;
    Color backgroundColor;
    
    if (step.isCompleted) {
      stepColor = AppColors.success;
      backgroundColor = AppColors.success.withValues(alpha: 0.1);
    } else if (step.isActive) {
      stepColor = AppColors.primary;
      backgroundColor = AppColors.primary.withValues(alpha: 0.1);
    } else {
      stepColor = AppColors.textHint;
      backgroundColor = AppColors.textHint.withValues(alpha: 0.05);
    }

    return InkWell(
      onTap: step.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: step.isActive
              ? Border.all(color: AppColors.primary, width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Icono del paso
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: stepColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                step.isCompleted ? Icons.check : step.icon,
                color: stepColor,
                size: 20.sp,
              ),
            ),
            
            SizedBox(width: 12.w),
            
            // Contenido del paso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: step.isCompleted || step.isActive 
                          ? AppColors.textPrimary 
                          : AppColors.textSecondary,
                    ),
                  ),
                  
                  SizedBox(height: 2.h),
                  
                  Text(
                    step.description,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  
                  // Mensaje de advertencia si existe
                  if (step.warningMessage != null) ...[
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: AppColors.warning,
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            step.warningMessage!,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Flecha si es clickeable
            if (step.onTap != null) ...[
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios,
                color: stepColor,
                size: 16.sp,
              ),
            ],
          ],
        ),
      ),
    );
  }
} 