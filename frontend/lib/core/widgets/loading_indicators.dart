import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Widget unificado para indicadores de carga circulares
class LoadingSpinner extends StatelessWidget {
  final Color? color;
  final double? size;
  final double? strokeWidth;

  const LoadingSpinner({
    super.key,
    this.color,
    this.size,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 12.w,
      height: size ?? 12.w,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: strokeWidth ?? 2.0,
      ),
    );
  }
}

/// Widget unificado para indicadores de carga en botones
class ButtonLoadingSpinner extends StatelessWidget {
  final Color? color;

  const ButtonLoadingSpinner({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return LoadingSpinner(
      color: color ?? Colors.white,
      size: 16.w,
      strokeWidth: 2.0,
    );
  }
}

/// Widget unificado para indicadores de carga con texto
class LoadingWithText extends StatelessWidget {
  final String text;
  final Color? spinnerColor;
  final TextStyle? textStyle;
  final MainAxisAlignment alignment;
  final double spacing;

  const LoadingWithText({
    super.key,
    required this.text,
    this.spinnerColor,
    this.textStyle,
    this.alignment = MainAxisAlignment.center,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: alignment,
      children: [
        LoadingSpinner(color: spinnerColor),
        SizedBox(height: spacing),
        Text(
          text,
          style: textStyle ?? AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Widget unificado para indicadores de carga en tarjetas
class CardLoadingState extends StatelessWidget {
  final String? text;
  final EdgeInsets? padding;

  const CardLoadingState({
    super.key,
    this.text,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(24.w),
      child: LoadingWithText(
        text: text ?? 'Cargando...',
        spinnerColor: AppColors.primary,
      ),
    );
  }
}

/// Widget unificado para indicadores de carga en grillas
class GridLoadingState extends StatelessWidget {
  final int itemCount;
  final double? itemHeight;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int crossAxisCount;

  const GridLoadingState({
    super.key,
    this.itemCount = 6,
    this.itemHeight,
    this.crossAxisSpacing = 16,
    this.mainAxisSpacing = 16,
    this.crossAxisCount = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: itemHeight != null 
          ? itemHeight! * ((itemCount / crossAxisCount).ceil()) + 
            (mainAxisSpacing * ((itemCount / crossAxisCount).ceil() - 1))
          : 400, // Altura por defecto
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: itemHeight != null ? 
            (MediaQuery.of(context).size.width / crossAxisCount) / itemHeight! : 
            1.2,
        ),
        itemCount: itemCount,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: const [AppColors.cardShadow],
            ),
            child: const CardLoadingState(),
          );
        },
      ),
    );
  }
}

/// Widget unificado para indicadores de carga lineales
class LinearLoading extends StatelessWidget {
  final Color? color;
  final Color? backgroundColor;
  final double? value;
  final String? text;

  const LinearLoading({
    super.key,
    this.color,
    this.backgroundColor,
    this.value,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (text != null) ...[
          Text(
            text!,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        LinearProgressIndicator(
          value: value,
          color: color ?? AppColors.primary,
          backgroundColor: backgroundColor ?? AppColors.primary.withValues(alpha: 0.2),
        ),
      ],
    );
  }
}

/// Widget unificado para estados de carga en SnackBars
class SnackBarLoading extends StatelessWidget {
  final String text;
  final Color? backgroundColor;

  const SnackBarLoading({
    super.key,
    required this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LoadingSpinner(
          color: Colors.white,
          size: 16.w,
          strokeWidth: 2.0,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  /// Método estático para mostrar SnackBar con loading
  static void show(
    BuildContext context,
    String text, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SnackBarLoading(
          text: text,
          backgroundColor: backgroundColor,
        ),
        backgroundColor: backgroundColor ?? Colors.blue,
        duration: duration,
      ),
    );
  }
}

/// Widget unificado para estados de carga centrados en pantalla completa
class FullScreenLoading extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;

  const FullScreenLoading({
    super.key,
    this.text,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor ?? AppColors.background,
      child: Center(
        child: LoadingWithText(
          text: text ?? 'Cargando...',
          spinnerColor: AppColors.primary,
        ),
      ),
    );
  }
}

/// Widget unificado para overlay de carga sobre contenido
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingText;
  final Color? overlayColor;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText,
    this.overlayColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: overlayColor ?? Colors.black.withValues(alpha: 0.3),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [AppColors.cardShadow],
                ),
                child: LoadingWithText(
                  text: loadingText ?? 'Cargando...',
                  spinnerColor: AppColors.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
} 