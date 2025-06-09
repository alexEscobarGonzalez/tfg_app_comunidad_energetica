import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;

  const LoadingWidget({
    super.key,
    this.height,
    this.width,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.surface,
      child: Container(
        height: height ?? 200.h,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.border,
          borderRadius: borderRadius ?? BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}

class LoadingListWidget extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const LoadingListWidget({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: LoadingWidget(height: itemHeight.h),
      ),
    );
  }
}

class LoadingCardWidget extends StatelessWidget {
  const LoadingCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LoadingWidget(height: 20.h, width: 200.w),
          SizedBox(height: 8.h),
          LoadingWidget(height: 16.h, width: 150.w),
          SizedBox(height: 16.h),
          LoadingWidget(height: 100.h),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: LoadingWidget(height: 14.h)),
              SizedBox(width: 16.w),
              Expanded(child: LoadingWidget(height: 14.h)),
            ],
          ),
        ],
      ),
    );
  }
} 